# Grab data from the API, once the URL is formatted correctly

load_data <- function(api_call) {

  request <- httr::GET(api_call)

  df <- data.frame(jsonlite::fromJSON(httr::content(request, as = 'text')), stringsAsFactors = FALSE)

  colnames(df) <- df[1, ]

  df <- df[-1, ]

  rownames(df) <- NULL

  string_cols <- names(df) %in% c("NAME", "FIPS")

  df[!string_cols] <- apply(df[!string_cols], 2, function(x) as.numeric(x))

  return(df)

}

