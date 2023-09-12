#' @title Install development version of pak
#' 
#' @description Occasionally `renv` may install a version of
#' `pak` that results in the `Cannot load glue from the private library`
#' error. Installing from `r-lib` seems to work, however: 
#' https://github.com/r-lib/pak/issues/339#issuecomment-1108238398.
#' This function wraps the command to do so.
#' @export
install_pak_devel <- function() {
  install.packages("pak", repos = "https://r-lib.github.io/p/pak/devel/")
}