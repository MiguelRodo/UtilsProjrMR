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
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    renv::install("ggplot2")
  }
  if (!requireNamespace("tibble", quietly = TRUE)) {
    renv::install("tibble")
  }
  if (!requireNamespace("here", quietly = TRUE)) {
    renv::install("here")
  }
  library(targets)
  # set project store and script
  dir_store <- projr::projr_dir_get("cache", "targets", proj_nm)
  dir_script <- file.path("scripts", "targets", proj_nm)
  if (!dir.exists(dir_script)) {
    dir.create(dir_script, recursive = TRUE)
  }
  tar_config_set(
    script = file.path(dir_store, "_targets.R"),
    store = file.path(dir_script, "_targets"),
    project = proj_nm
  )
  if (!file.exists(file.path(dir_script, "_targets.R"))) {
    file.copy(
      system.file("scripts", "_targets.R", package = "UtilsProjrMR"),
      file.path(dir_script, "_targets.R")
    )
  }
  Sys.setenv("TAR_PROJECT" = proj_nm)
  for (x in list.files(here::here("R"), pattern = "R$|r$", full.names = TRUE)) {
    source(x)
  }
  invisible(TRUE)
}
#' @export
projr_tar_project_setup <- projr_tar_project_set_up
