#' @title Create a targets pipeline
#'
#' @description Creates a targets pipeline
#' corresponding to a specific targets name.
#' Stores the output in the temp directory,
#' and stores the scripts in `scripts/targets`.
#' Cats out text to add to Rmd file.
#'
#' @param proj_nm
#' character.
#' Name of project.
#'
#' @export
projr_tar_pipeline_create <- function(proj_nm) {
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
    script = file.path(dir_script, "_targets.R"),
    store = file.path(dir_store, "_targets"),
    project = proj_nm
  )
  if (!file.exists(file.path(dir_script, "_targets.R"))) {
    file.copy(
      system.file("scripts", "_targets.R", package = "UtilsProjrMR"),
      file.path(dir_script, "_targets.R")
    )
  }

  projr_tar_pipeline_activate(proj_nm = proj_nm)

  print("Place the below in the script running the `targets` pipeline:")
  cat(
    'Sys.setenv("TAR_PROJECT" = "', proj_nm, '")', "\n",
    "targets::tar_make()", "\n",
    "targets::tar_load_globals()", "\n",
    sep = ""
  )

  invisible(TRUE)
}

#' @title Activate a `targets` pipeline
#'
#' @description Sources all files in `R/` and
#' runs `Sys.setenv("TAR_PROJECT" = <proj_nm>)`.
#'
#' @param proj_nm character.
#' Name of \code{targets} pipeline (project).
#' @export
projr_tar_pipeline_activate <- function(proj_nm) {
  Sys.setenv("TAR_PROJECT" = proj_nm)
  for (x in list.files(here::here("R"), pattern = "R$|r$", full.names = TRUE)) {
    source(x)
  }
  invisible(TRUE)
}
