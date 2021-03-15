# Grab data from the API, once the URL is formatted correctly

load_data <- function(api_call) {

  request <- httr::GET(api_call)

  cont <- httr::content(request, as = 'text')

  if (jsonlite::validate(cont) == FALSE) {

    stop("You have supplied an invalid query.  Consider revising your year selection (IDB data begin at 1950, and are not available for many countries until 1990), or use `idb_variables()` or `idb_concepts()` to view valid choices of variables and concepts.", call. = FALSE)

  } else {

    df <- data.frame(jsonlite::fromJSON(cont), stringsAsFactors = FALSE)

    colnames(df) <- df[1, ]

    df <- df[-1, ]

    rownames(df) <- NULL

    string_cols <- names(df) %in% c("NAME", "FIPS")

    df[!string_cols] <- apply(df[!string_cols], 2, function(x) as.numeric(x))

    return(dplyr::as_tibble(df))

  }

}

