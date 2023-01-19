#' @title Make .Rprofile source script to make renv use scratch directory
#'
#' @export
projr_rprofile_hpc_renv_setup <- function() {
  if (!file.exists(".Rprofile")) {
    file.create(".Rprofile")
  }
  txt_rprofile <- readLines(".Rprofile")
  txt_rprofile <- c(
    txt_rprofile,
    "\n# make renv use scratch directory",
    "slurm_ind <- any(grepl("^SLURM_", names(Sys.getenv())))",
    'dir_exists_ind <- dir.exists(file.path("/scratch/", Sys.getenv("USER")))',
    'if (slurm_ind && dir_exists_ind) {',
    '  source("./scripts/hpc_renv_setup.R")',
    "}"
  )
  writeLines(txt_rprofile, ".Rprofile")
  if (!dir.exists("scripts")) {
    dir.create("scripts")
  }
  file.copy(
    system.file("scripts", "hpc_renv_setup.R", package = "UtilsProjrMR"),
    "scripts/hpc_renv_setup.R"
  )
  slurm_ind <- any(grepl("^SLURM_", names(Sys.getenv())))
  dir_exists_ind <- dir.exists(file.path("/scratch/", Sys.getenv("USER")))
  if (slurm_ind && dir_exists_ind) {
    source("./scripts/hpc_renv_setup.R")
  }
  invisible(TRUE)
}

#' @title Make .Rprofile source script to make renv use right repos
#'
#' @description Copied from
#' \url{https://github.com/rstudio/renv/issues/1052#issuecomment-1342567839}.
#'
#' @export
projr_rprofile_renv_repos <- function() {
  if (!file.exists(".Rprofile")) {
    file.create(".Rprofile")
  }
  txt_rprofile <- readLines(".Rprofile")
  txt_rprofile <- c(
    txt_rprofile,
    "\n# enable renv to use binaries across OSs",
    'source("./scripts/renv_repos.R")'
  )
  writeLines(txt_rprofile, ".Rprofile")
  if (!dir.exists("scripts")) {
    dir.create("scripts")
  }
  file.copy(
    system.file("scripts", "renv_repos.R", package = "UtilsProjrMR"),
    "scripts/renv_repos.R"
  )
  source("scripts/renv_repos.R")
  invisible(TRUE)
}

projr_rprofile_dev <- function() {
  if (!file.exists(".Rprofile")) {
    file.create(".Rprofile")
  }
  txt_rprofile <- readLines(".Rprofile")
  txt_rprofile <- c(
    txt_rprofile,
    "\n# add commonly-used dev functions and attached libraries",
    'source("./scripts/dev.R")'
  )
  writeLines(txt_rprofile, ".Rprofile")
  if (!dir.exists("scripts")) {
    dir.create("scripts")
  }
  file.copy(
    system.file("scripts", "dev.R", package = "UtilsProjrMR"),
    "scripts/dev.R"
  )
  source("scripts/dev.R")
  invisible(TRUE)
}
