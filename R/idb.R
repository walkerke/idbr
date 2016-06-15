#' Retrieve data from the single-year-of-age IDB dataset.
#'
#' @param country The two-character country FIPS code, or a valid country name.
#' @param year The year for which you'd like to retrieve data
#' @param variables A vector of variables.  If left blank, will return age, area in square kilometers, the name of the country, and the population size of the age group.
#' @param start_age (optional) The first age for which you'd like to retrieve data.
#' @param end_age (optional) The second age group for which you'd like to retrieve data.
#' @param sex (optional) One of 'both', 'male', or 'female'.
#' @param api_key The user's Census API key.  Can be supplied here or set globally in an idbr session with
#' \code{idb_api_key(api_key)}.
#'
#' @return A data frame with the requested data.
#' @seealso \url{http://api.census.gov/data/timeseries/idb/1year.html}
#' @examples \dontrun{
#'
#' # Projected population pyramid of China in 2050 with idbr and plotly
#'
#' library(idbr)
#' library(plotly)
#' library(dplyr)
#'
#' idb_api_key('Your API key goes here')
#'
#' male <- idb1('CH', 2050, sex = 'male') %>%
#'   mutate(POP = POP * -1,
#'          SEX = 'Male')
#'
#' female <- idb1('CH', 2050, sex = 'female') %>%
#'    mutate(SEX = 'Female')
#
#' china <- rbind(male, female) %>%
#'    mutate(abs_pop = abs(POP))
#
#' plot_ly(china, x = POP, y = AGE, color = SEX, type = 'bar', orientation = 'h',
#'         hoverinfo = 'y+text+name', text = abs_pop, colors = c('red', 'gold')) %>%
#'   layout(bargap = 0.1, barmode = 'overlay',
#'          xaxis = list(tickmode = 'array', tickvals = c(-10000000, -5000000, 0, 5000000, 10000000),
#'                      ticktext = c('10M', '5M', '0', '5M', '10M')),
#'          title = 'Projected population structure of China, 2050')
#'
#' }
#' @export
idb1 <- function(country, year, variables = c('AGE', 'AREA_KM2', 'NAME', 'POP'),
                 start_age = NULL, end_age = NULL, sex = NULL, api_key = NULL) {

  if (Sys.getenv('IDB_API') != '') {

    api_key <- Sys.getenv('IDB_API')

  } else if (is.null(api_key)) {

    stop('A Census API key is required.  Obtain one at http://api.census.gov/data/key_signup.html, and then supply the key to the `idb_api_key` function to use it throughout your idbr session.')

  }

  if (length(country) > 1) {

    stop('The option to supply multiple countries to a single `idb1` call is not yet supported.')

  }

  if (nchar(country) > 2) {

    country <- countrycode::countrycode(country, 'country.name', 'fips104')

  }

  if (!(country %in% valid_countries)) {

    stop(paste0('The FIPS code ', country, ' is not available in the Census IDB.'))

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



#' Retrieve data from the five-year-age-group IDB dataset.
#'
#' @param country A two-character FIPS code or country name, or a vector of FIPS codes or country names,
#' of the countries for which you'd like to retrieve data.
#' @param year A year, or a vector of years, for which you'd like to retrieve data.
#' @param variables A vector of variables.  Use \code{idb_variables()} for a full list.
#' @param concept A concept for which you'd like to retrieve data.
#' Use \code{idb_concepts()} for a list of options.
#' @param country_name If TRUE, returns a column with the long country name along with the FIPS code.
#' @param api_key The user's Census API key.  Can be supplied here or set globally in an idbr session with
#' \code{idb_api_key(api_key)}.
#'
#' @return A data frame with the requested data.
#' @seealso \url{http://api.census.gov/data/timeseries/idb/5year.html}
#' @examples \dontrun{
#'
#' # World map of infant mortality rates by country for 2016 with plotly
#'
#' library(idbr)
#' library(plotly)
#' library(viridis)
#'
#' idb_api_key('Your API key goes here')
#'
#' df <- idb5(country = 'all', year = 2016, variable = 'IMR', country_name = TRUE)
#'
#' plot_ly(df, z = IMR, text = NAME, locations = NAME, locationmode = 'country names',
#'         type = 'choropleth', colors = viridis(99), hoverinfo = 'text+z') %>%
#'   layout(title = 'Infant mortality rate (per 1000 live births), 2016',
#'          geo = list(projection = list(type = 'robinson')))
#'
#'
#' }
#' @export
idb5 <- function(country, year, variables = NULL, concept = NULL, country_name = FALSE, api_key = NULL) {

  if (Sys.getenv('IDB_API') != '') {

    api_key <- Sys.getenv('IDB_API')

  } else if (is.null(api_key)) {

    stop('A Census API key is required.  Obtain one at http://api.census.gov/data/key_signup.html, and then supply the key to the `idb_api_key` function to use it throughout your idbr session.')

  }

  suppressWarnings(if (country == 'all') {

    country <- valid_countries

    } else {

      country <- vapply(country, function(x) {

        if (nchar(x) > 2) {

          return(countrycode::countrycode(x, 'country.name', 'fips104'))

        } else {

          return(x)

        }

      }, character(1))

    })

  if (any(is.na(!match(country, valid_countries))) == TRUE) {

    nomatch <- country[is.na(!match(country, valid_countries))]

    country <- country[!country %in% nomatch]

    warning(paste0('The FIPS codes ', paste(nomatch, sep = ' ', collapse = ', '),
                   ' are not available in the Census IDB, and have been removed from your query.'))

  }

  if (length(variables) > 50) {

    stop("Requests are limited to 50 variables.  Consider using `idb_variables()` to identify which variables to select, or `idb_concepts()` to identify a concept by which you can subset.", call. = FALSE)

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
#' Use to set the Census API key in an idbr session so that the key does not have to be passed to each
#' \code{idb1} or \code{idb5} function call.
#'
#' @param api_key The idbr user's Census API key.  Can be obtained from \url{http://api.census.gov/data/key_signup.html}.
#'
#' @examples \dontrun{
#'
#' idb_api_key('Your API key goes here')
#'
#' }
#' @export
idb_api_key <- function(api_key) {

  Sys.setenv(IDB_API = api_key)

}




