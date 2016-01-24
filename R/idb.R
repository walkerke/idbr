#' Retrieve data from the single-year-of-age IDB dataset
#'
#' @param country The two-character country FIPS code
#' @param year The year for which you'd like to retrieve data
#' @param variables A vector of variables.  If left blank, will return age, area in square kilometers, the name of the country, and the population size of the age group.
#' @param start_age (optional) The first age for which you'd like to retrieve data.
#' @param end_age (optional) The second age group for which you'd like to retrieve data.
#' @param sex (optional) One of 'both', 'male', or 'female'.
#'
#' @return A data frame with the requested data.
#'
#' @export
idb1 <- function(country, year, variables = c('AGE', 'AREA_KM2', 'NAME', 'POP'),
                 start_age = NULL, end_age = NULL, sex = NULL, api_key = NULL) {

  if (Sys.getenv('IDB_API') != '') {

    api_key <- Sys.getenv('IDB_API')

  } else if (is.null(api_key)) {

    stop('A Census API key is required.  Obtain one at http://api.census.gov/data/key_signup.html, and then supply the key to the `idb_api_key` function to use it throughout your IDBr session.')

  }

  if (any(is.na(!match(country, valid_countries))) == TRUE) {

    nomatch <- country[is.na(!match(country, valid_countries))]

    country <- country[!country %in% nomatch]

    warning(paste0('The FIPS codes ', paste(nomatch, sep = ' ', collapse = ', '),
                   ' are not available in the Census IDB, and have been removed from your query.'))

  }

  variables <- paste(variables, sep = '', collapse = ',')

  if (length(year) == 1) {

    url <- paste0(
      'http://api.census.gov/data/timeseries/idb/1year?get=',
      variables,
      '&FIPS=',
      country,
      '&time=',
      as.character(year),
      '&key=',
      api_key
    )

    if (!is.null(start_age) & !is.null(end_age)) {

      url <- paste0(url, '&AGE=', as.character(start_age), ':', as.character(end_age))

    } else if (!is.null(start_age) & is.null(end_age)) {

      url <- paste0(url, '&AGE=', as.character(start_age), ':100')

    } else if (is.null(start_age) & !is.null(end_age)) {

      url <- paste0(url, '&AGE=0:', as.character(end_age))

    }

    if (!is.null(sex)) {

      if (sex == 'both') sex <- 0

      if (sex == 'male') sex <- 1

      if (sex == 'female') sex <- 2

      url <- paste0(url, '&SEX=', as.character(sex))

    }

    return(load_data(url))

  } else if (length(year) > 1) {

    dfs <- lapply(year, function(x) {

      url <- paste0(
        'http://api.census.gov/data/timeseries/idb/1year?get=',
        variables,
        '&FIPS=',
        country,
        '&time=',
        as.character(x),
        '&key=',
        api_key
      )

      if (!is.null(start_age) & !is.null(end_age)) {

        url <- paste0(url, '&AGE=', as.character(start_age), ':', as.character(end_age))

      } else if (!is.null(start_age) & is.null(end_age)) {

        url <- paste0(url, '&AGE=', as.character(start_age), ':100')

      } else if (is.null(start_age) & !is.null(end_age)) {

        url <- paste0(url, '&AGE=0:', as.character(end_age))

      }

      if (!is.null(sex)) {

        if (sex == 'both') sex <- 0

        if (sex == 'male') sex <- 1

        if (sex == 'female') sex <- 2

        url <- paste0(url, '&SEX=', as.character(sex))

      }

      load_data(url)

    })

    return(dplyr::bind_rows(dfs))

  }

}



#' Retrieve data from the five-year-age-group IDB dataset
#'
#' @param country A two-character FIPS code, or a vector of FIPS codes, of the countries for which you'd like to retrieve data.
#' @param year A year, or a vector of years, for which you'd like to retrieve data.
#' @param variables A vector of variables.  Use `idb_variables()` for a full list.
#' @param concept A concept for which you'd like to retrieve data.  Use `idb_concepts()` for a list of options.
#' @param country_name If TRUE, returns a column with the long country name along with the FIPS code.
#'
#' @return A data frame with the requested data.
#' @export
idb5 <- function(country, year, variables = NULL, concept = NULL, country_name = FALSE, api_key = NULL) {

  if (Sys.getenv('IDB_API') != '') {

    api_key <- Sys.getenv('IDB_API')

  } else if (is.null(api_key)) {

    stop('A Census API key is required.  Obtain one at http://api.census.gov/data/key_signup.html, and then supply the key to the `idb_api_key` function to use it throughout your IDBr session.')

  }

  if (any(is.na(!match(country, valid_countries))) == TRUE) {

    nomatch <- country[is.na(!match(country, valid_countries))]

    country <- country[!country %in% nomatch]

    warning(paste0('The FIPS codes ', paste(nomatch, sep = ' ', collapse = ', '),
                   ' are not available in the Census IDB, and have been removed from your query.'))

  }

  if (!is.null(variables)) {

    if (!is.null(concept)) {

      concept <- NULL

      warning('concept cannot be used with variables; using the specified variables instead.', call. = FALSE)

    }

    variables <- paste(variables, sep = '', collapse = ',')

  } else if (is.null(variables) & is.null(concept)) {

    stop("Requests are limited to 50 variables.  Consider using `idb_variables()` to identify which variables to select, or `idb_concepts()` to identify a concept by which you can subset.", call. = FALSE)

  } else if (is.null(variables) & !is.null(concept)) {

    sub <- variables5[variables5$Concept == concept, ]

    vars <- unique(sub$Name)

    variables <- paste(vars, sep = '', collapse = ',')

  }

  if (country_name == TRUE) variables <- paste0(variables, ',NAME')


  if (length(country) == 1 & length(year) == 1) {

    url <- paste0(
      'http://api.census.gov/data/timeseries/idb/5year?get=',
      variables,
      '&FIPS=',
      country,
      '&time=',
      as.character(year),
      '&key=',
      api_key
    )

    return(load_data(url))

  } else if (length(country) > 1 & length(year) == 1) {

    dfs <- lapply(country, function(x) {

      url <- paste0(
        'http://api.census.gov/data/timeseries/idb/5year?get=',
        variables,
        '&FIPS=',
        x,
        '&time=',
        as.character(year),
        '&key=',
        api_key
      )

      load_data(url)

    })

    return(dplyr::bind_rows(dfs))

  } else if (length(country) == 1 & length(year) > 1) {

    dfs <- lapply(year, function(x) {

      url <- paste0(
        'http://api.census.gov/data/timeseries/idb/5year?get=',
        variables,
        '&FIPS=',
        country,
        '&time=',
        as.character(x),
        '&key=',
        api_key
      )

      load_data(url)

    })

    return(dplyr::bind_rows(dfs))

  } else if (length(country) > 1 & length(year) > 1) {

    full <- lapply(country, function(x) {

      dfs <- lapply(year, function(y) {

        url <- paste0(
          'http://api.census.gov/data/timeseries/idb/5year?get=',
          variables,
          '&FIPS=',
          x,
          '&time=',
          as.character(y),
          '&key=',
          api_key
        )

        load_data(url)

      })

      dplyr::bind_rows(dfs)

    })

    return(dplyr::bind_rows(full))

  }

}

#' Set the Census API key
#'
#' @export
idb_api_key <- function(api_key) {

  Sys.setenv(IDB_API = api_key)

}




