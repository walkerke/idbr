#' Get Data from the US Census Bureau's International Data Base API
#'
#' @param country A country name or vector of country names. Can be specified as ISO-2 codes
#'                as well. Use \code{country = "all"} to request all countries available in
#'                the IDB.
#' @param year A single year or vector of years for which you'd like to request data.
#' @param variables A character string or vector of variables representing data you would like
#'                  to request.  If you are specifying an age or sex subset, this should be kept as                     \code{NULL} as the function will return data from the 1-year-of-age IDB API.
#'                  If filtering by age or sex, should be NULL.
#' @param concept Variables in the IDB are organized by concepts; if specified, request all
#'                variables for a given concept.  Use \code{idb_concepts()} to view
#'                available concepts.
#' @param age A vector of ages for which you would like to request population data. If specified,                 will return data from the 1-year-age-band IDB API.  Should not be used when
#'            \code{variables} is not \code{NULL}.
#' @param sex One or more of "both", "male", or "female". If specified, will return data
#'            from the 1-year-age-band IDB API.  Should not be used when \code{variables}
#'            is not \code{NULL}.
#' @param geometry If \code{TRUE}, returns country simple feature geometry along with your data
#'                 which can be used for mapping. Geometry is obtained using the rnaturalearthdata
#'                 R package.
#' @param resolution one of \code{"low"} for lower-resolution (less-detailed) geometry, or          #'                   \code{"high"} for more detailed geometry.  It is recommended to use the low-
#'                   resolution geometries for smaller-scale (e.g. world) mapping, and the
#'                   higher-resolution geometries for medium-scale (e.g. regional) mapping.
#' @param api_key Your Census API key.  Can be supplied as part of the function call or
#'                set globally with the \code{idb_api_key()} function. If you are a tidycensus
#'                user with your API key already stored, \code{get_idb()} will pick up the
#'                API key from there, and no further action from you is required.
#'
#' @return A tibble or sf tibble of data from the International Data Base API.
#' @export
#'
#' @examples \dontrun{
#' # Get data from the 1-year-age-band dataset by sex for China from
#' # 1990 through 2021
#'
#' library(idbr)
#'
#' china_data <- get_idb(
#'   country = "China",
#'   year = 1990:2021,
#'   age = 1:100,
#'   sex = c("male", "female")
#'  )
#'
#' # Get data on life expectancy at birth for all countries in 2021 and
#' # make a map with ggplot2
#'
#' library(idbr)
#' library(tidyverse)
#'
#' lex <- get_idb(
#'   country = "all",
#'   year = 2021,
#'   variables = c("name", "e0"),
#'   geometry = TRUE
#' )
#
#' ggplot(lex, aes(fill = e0)) +
#'   theme_bw() +
#'   geom_sf() +
#'   coord_sf(crs = 'ESRI:54030') +
#'   scale_fill_viridis_c() +
#'   labs(fill = "Life expectancy at birth (2021)")
#' }
get_idb <- function(country,
                    year,
                    variables = NULL,
                    concept = NULL,
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

  if (!is.null(concept)) {
    variables <- idbr::variables5 %>%
      dplyr::filter(Concept == concept) %>%
      dplyr::pull(Name)
  }

  if (!is.null(age) || !is.null(sex)) {
    if (is.null(variables)) {
      variables <- "NAME,POP"
    } else {
      stop("`variables` or `concept` cannot be used with age or sex subsets, which query the 1-year-of-age population API.  Specify a vector of variables and leave `AGE` and `SEX` as `NULL` to complete your request.", call. = FALSE)
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

  # Account for when age/sex are specified but the other is not
  if (is.null(sex) && !is.null(age)) {
    sex <- "both"
  }

  if (!is.null(sex) && is.null(age)) {
    age <- 0:100
  }

  if (!is.null(sex)) {

    sex_ints <- purrr::map_chr(sex, ~{
      if (.x == "both") return(0L)
      if (.x == "male") return(1L)
      if (.x == "female") return(2L)
    }) %>%
      paste0(collapse = ",")

  } else {
    sex_ints <- NULL
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
                             SEX = sex_ints,
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

  if ("sex" %in% names(out_tibble)) {
    out_tibble$sex <- dplyr::recode(out_tibble$sex,
      `0` = "Both",
      `1` = "Male",
      `2` = "Female"
    )
  }

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

    # Should be left join if country is all, to make missing countries NULL
    # Not perfect yet, e.g. for regional mapping with missing countries
    if (all(country == "all")) {

      joined_tbl <- geom %>%
        dplyr::left_join(out_tibble, by = "code")

    } else {

      joined_tbl <- geom %>%
        dplyr::inner_join(out_tibble, by = "code")

    }

    return(joined_tbl)
  } else {
    return(out_tibble)
  }

}