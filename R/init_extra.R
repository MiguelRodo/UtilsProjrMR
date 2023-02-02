#' @title Add extra bits to project set-up
#'
#' @description
#' Makes .Rprofile set up renv for HPC and to use binaries,
#' attaches useful functions and packages and installs
#' packages useful for VS Code.
#'
#' @export
projr_init_extra <- function() {
  projr_rprofile_hpc_renv_setup()
  projr_rprofile_renv_repos()
  projr_rprofile_dev()
  projr_renv_dep_add(c("languageserver", "nx10/httpgd", "devtools", "jsonlite"))
  invisible(TRUE)
}
