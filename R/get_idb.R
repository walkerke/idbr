#' Get Data from the US Census Bureau's International Data Base API
#'
#' @param country A country name or vector of country names.
#' @param year A year, or vector of years
#' @param variables The variables you'd like to request.  If filtering by age or sex, should be NULL.
#' @param age A vector of ages
#' @param sex Either NULL (both sexes, the default), "male", or "female"
#' @param geometry Not yet implemented
#' @param resolution "high" or "low"
#' @param api_key Your key
#'
#' @return Data from the IDB!
#' @export
get_idb <- function(country,
                    year,
                    variables = NULL,
                    age = NULL,
                    sex = NULL,
                    geometry = FALSE,
                    resolution = c("low", "high"),
                    api_key = NULL) {

  if (Sys.getenv('IDB_API') != '') {

    api_key <- Sys.getenv('IDB_API')

  } else if (is.null(api_key)) {

    # Check if tidycensus API key is available

    if (Sys.getenv("CENSUS_API_KEY") != '') {
      api_key <- Sys.getenv("CENSUS_API_KEY")
    } else {
      stop('A Census API key is required.  Obtain one at https://api.census.gov/data/key_signup.html, and then supply the key to the `idb_api_key` function to use it throughout your idbr session.')
    }

  }

  if (!is.null(age) || !is.null(sex)) {
    base_url <- "https://api.census.gov/data/timeseries/idb/1year"
  } else {
    base_url <- "https://api.census.gov/data/timeseries/idb/5year"
  }

  if (!is.null(age) || !is.null(sex)) {
    if (is.null(variables)) {
      variables <- "NAME,POP"
    } else {
      stop("`variables` cannot be used with age or sex subsets, which query the 1-year-of-age population API.  Specify a vector of variables and leave `AGE` and `SEX` as `NULL` to complete your request.", call. = FALSE)
    }
  }

  country_vector <- NULL
  # If more than one country is requested, pull all countries then filter down
  if (length(country) > 1 || all(country == "all")) {
    country_to_use <- NULL
    if (all(country != "all")) {
      country_vector <- countrycode::countrycode(country, 'country.name', 'iso2c')
    }
  } else {
    if (nchar(country) > 2) {
      country_to_use <- countrycode::countrycode(country, 'country.name', 'iso2c')
    } else {
      country_to_use <- country
    }
  }

  if (is.null(sex) && !is.null(age)) {
    sex <- "both"
  }

  if (!is.null(sex)) {

    if (sex == 'both') sex <- 0

    if (sex == 'male') sex <- 1

    if (sex == 'female') sex <- 2

  }

  # Format age and year, if appropriate
  if (!is.null(age)) {
    age <- paste0(age, collapse = ",")
  }

  year <- paste0(year, collapse = ",")

  if (length(variables) > 1) {
    variables <- paste0(variables, collapse = ",")
  }

  if (is.null(country_to_use)) {
    variables <- paste0("GENC,", variables)
  }

  variables <- toupper(variables)

  # Formulate the query
  api_request <- httr::GET(base_url,
                           query = list(
                             get = variables,
                             SEX = sex,
                             YR = year,
                             AGE = age,
                             GENC = country_to_use,
                             key = api_key
                           ))

  req_content <- httr::content(api_request, as = "text")

  if (api_request$status_code != "200") {
    stop(sprintf("Your data request has errored.  The error message returned is %s",
                 req_content))
  }

  req_frame <- data.frame(jsonlite::fromJSON(req_content), stringsAsFactors = FALSE)

  colnames(req_frame) <- req_frame[1, ]

  req_frame <- req_frame[-1, ]

  rownames(req_frame) <- NULL

  string_cols <- names(req_frame) %in% c("NAME", "GENC")

  req_frame[!string_cols] <- apply(req_frame[!string_cols], 2, function(x) as.numeric(x))

  req_tibble <- dplyr::as_tibble(req_frame)

  names(req_tibble) <- tolower(names(req_tibble))

  out_tibble <- dplyr::select(req_tibble, code = genc, year = yr, dplyr::everything())

  if (!is.null(country_vector)) {
    out_tibble <- out_tibble %>%
      dplyr::filter(code %in% country_vector)
  }

  if (geometry) {
    resolution <- match.arg(resolution)

    if (resolution == "low") {
      geom <- rnaturalearthdata::countries110 %>%
        sf::st_as_sf() %>%
        dplyr::select(code = iso_a2)
    } else {
      geom <- rnaturalearthdata::countries50 %>%
        sf::st_as_sf() %>%
        dplyr::select(code = iso_a2)
    }

    joined_tbl <- geom %>%
      dplyr::inner_join(out_tibble, by = "code")

    return(joined_tbl)
  } else {
    return(out_tibble)
  }




}