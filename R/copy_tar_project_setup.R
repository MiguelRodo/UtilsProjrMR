copy_tar_project_setup <- function() {
  file.copy(
    system.file(
      "scripts", "tar_project_setup.R",
      package = "UtilsProjrMR"
    ),
    "R/tar_project_setup.R"
  )
}
copy_tar_project_set_up <- copy_tar_project_setup
