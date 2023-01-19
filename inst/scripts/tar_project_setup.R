projr_tar_project_set_up <- function(proj_nm) {
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
projr_tar_project_setup <- projr_tar_project_set_up
