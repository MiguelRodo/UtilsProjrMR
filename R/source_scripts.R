#' @title Source all R scripts
#'
#' @description Convenience function for sourcing
#' all \code{R} scripts in \code{"R/"} folder.
#'
#' @export
projr_source_script_r <- function() {
  for (x in list.files(here::here("R"), pattern = "R$|r$", full.names = TRUE)) {
    source(x)
  }
}
