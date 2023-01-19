#' @title Set up a `targets` pipeline
#'
#' @description Attaches the \code{targets} package,
#' configures the pipeline to exist in
#' \code{projr_dir_get("cache", "targets", projr_nm)}
#' and sets the system environment variable
#' \code{TAR_PROJECT} to \code{proj_nm}.
#' @param proj_nm character
#'
#' @export
projr_tar_project_set_up <- function(proj_nm) {
  if (!requireNamespace("targets", quietly = TRUE)) {
    renv::install("targets")
  }
  if (!requireNamespace("projr", quietly = TRUE)) {
    renv::install("SATVILab/projr")
  }
  library(targets)
  # set project store and script
  dir_proj <- projr_dir_get("cache", "targets", proj_nm)
  targets::tar_config_set(
    script = file.path(dir_proj, "_targets.R"),
    store = file.path(dir_proj, "_targets"),
    project = proj_nm
  )
  Sys.setenv("TAR_PROJECT" = proj_nm)
  invisible(TRUE)
}
#' @export
projr_tar_project_setup <- projr_tar_project_set_up
