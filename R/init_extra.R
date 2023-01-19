projr_init_extra <- function() {
  projr_rprofile_hpc_renv_setup()
  projr_rprofile_dev()
  projr_renv_dep_add(c("languageserver", "httpgd", "devtools", "jsonlite"))
  invisible(TRUE)
}
