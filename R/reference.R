#' Print the available concepts to pass to the `idb5()` function.
#'
#' @export
idb_concepts <- function() {

  print(unique(idbr::variables5$Concept))

}

#' View the available variables for use in idbr
#'
#' The first column, "Name", details the variable names that can be passed the function.  The second column, "Label", describes the content of the variables.
#'
#' @export
idb_variables <- function() {

  return(dplyr::tibble(idbr::variables5[,1:2]))

}


