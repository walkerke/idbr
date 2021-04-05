# Grab data frame of variables from Census website

library(rvest)

url <- 'https://api.census.gov/data/timeseries/idb/5year/variables.html'

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

# Get vector of valid countries

df <- read.csv('data-raw/IDBext001.txt', sep = '|', header = FALSE, stringsAsFactors = FALSE)

vals <- unique(df$V1)

dput(vals)

