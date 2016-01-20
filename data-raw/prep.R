library(jsonlite)

url <- 'http://api.census.gov/data/timeseries/idb/5year?get=NAME,POP,CBR,CDR,YR,AREA_KM2&FIPS=NO&time=2015'

url2 <- 'http://api.census.gov/data/timeseries/idb/5year?get=NAME,POP,CBR,CDR,YR,AREA_KM2&FIPS=NO&time=2014'

u <- fromJSON(url)

v <- fromJSON(url2)

df <- data.frame(fromJSON(url), stringsAsFactors = FALSE)

colnames(df) <- df[1, ]

df <- df[-1, ]

rownames(df) <- NULL


load_data <- function(api_call) {

  df <- data.frame(jsonlite::fromJSON(api_call), stringsAsFactors = FALSE)

  colnames(df) <- df[1, ]

  df <- df[-1, ]

  rownames(df) <- NULL

  return(df)

}

idb1 <- function(country, year, variables = 'all', start_age = NULL, end_age = NULL, sex = NULL) {

  if (variables == 'all') {

    variables <- 'AGE,AREA_KM2,NAME,POP'

  } else {

    variables <- paste(variables, sep = '', collapse = ',')

  }

  url <- paste0(
    'http://api.census.gov/data/timeseries/idb/1year?get=',
    variables,
    '&FIPS=',
    country,
    '&time=',
    as.character(year)
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

}



df <- idb1('US', 2014)


idb5 <- function...


# Grab data frame of variables from Census website

library(rvest)

url <- 'http://api.census.gov/data/timeseries/idb/5year/variables.html'

df <- url %>%
  html() %>%
  html_nodes('table') %>%
  html_table() %>%
  data.frame()

df <- df[-1,]

row.names(df) <- NULL

variables5 <- df

variables5$Concept[18:38] <- 'Female midyear population by 5-year age groups'

variables5$Concept[47:67] <- 'Male midyear population by 5-year age groups'

variables5$Concept[73:93] <- 'Total midyear population by 5-year age groups'

save(variables5, file = 'data/variables5.rda')