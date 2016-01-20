#' Print the available concepts to pass to the `idb5()` function.
#'
#' @export
idb_concepts <- function() {

  print(unique(variables5$Concept))

}

#' Print the available variables to pass to the `idb5()` function.
#'
#' The first column, "Name", details the variable names that can be passed the function.  The second column, "Label", describes the content of the variables.
#'
#' @export
idb_variables <- function() {

  print(variables5[,1:2])

}


