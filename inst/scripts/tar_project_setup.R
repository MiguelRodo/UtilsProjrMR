tar_project_set_up <- function(proj_nm) {
  library(targets)
  project_yml <- yaml::read_yaml(here::here("_projr.yml"))
  # set project store and script
  dir_proj <- file.path(projr_dir_get("cache"), "targets", proj_nm)
  if (!dir.exists(dir_proj)) dir.create(dir_proj, recursive = TRUE)
  targets::tar_config_set(
    script = file.path(dir_proj, "_targets.R"),
    store = file.path(dir_proj, "_targets"),
    project = proj_nm
  )
  Sys.setenv("TAR_PROJECT" = proj_nm)
  invisible(TRUE)
}
