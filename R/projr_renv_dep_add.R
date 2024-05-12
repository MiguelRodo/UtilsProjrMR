#' @title Adds a package to _dependencies.R file for renv to pick up
#'
#' @description Adds \code{library(<pkg>)} for each
#' package listed. Installs them if they're not already installed.
#' @param pkg character vector.
#' Packages to add to _dependencies.R, and install
#' if not already installed.
#' Can use "<remote>/<repo>" syntax for installing from
#' (GitHub) remotes, as long as \code{<repo>} is also
#' the name of the package.
#' @export
projr_renv_dep_add <- function(pkg) {
  pkg_inst <- pkg[
    sapply(
      pkg, function(x) {
        !requireNamespace(gsub("^\\w+/", "", x), quietly = TRUE)
      }
    )
  ]
  if (length(pkg_inst) > 0) {
    renv::install(pkg_inst)
  }
  if (!file.exists("_dependencies.R")) {
    file.create("_dependencies.R")
  }
  txt_dep <- readLines("_dependencies.R")
  for (x in pkg) {
    txt_add <- paste0("library(", gsub("^\\w+/", "", x), ")")
    if (!txt_add %in% txt_dep) {
      txt_dep <- c(txt_dep, txt_add)
    }
  }
  writeLines(txt_dep, "_dependencies.R")
  invisible(TRUE)
}

#' @title Restore
#' @export
projr_renv_restore_update <- function(restore_gh = TRUE) {

  .projr_renv_lockfile_pkg_get() |>
    .projr_renv_restore_update(restore_gh = restore_gh)

  invisible(TRUE)
}

.projr_renv_restore_update(pkg, restore_gh) {
  if (restore_gh) {
    .projr_renv_restore_update_restore_gh(pkg)
  } else {
    .projr_renv_restore_update_restore_gh_n(pkg)
  }
  invisible(TRUE)
}

.projr_renv_lockfile_pkg_get <- function() {
  lockfile_list_pkg <- renv::lockfile_read()$Package
  pkg_vec <- NULL
  for (i in seq_along(lockfile_list_pkg)) {
    pkg_list <- lockfile_list_pkg[[i]]
    pkg <- pkg_list$Package
    remote_username <- pkg_list$RemoteUsername
    if (is.null(remote_username)) {
      pkg_vec <- c(pkg, pkg_vec)
    } else {
      pkg_vec <- c(pkg_vec, paste0(remote_username, "/", pkg))
    }
  }
  pkg_vec
}

.projr_renv_restore_update_restore_gh <- function(pkg) {
  pkg_non_gh <- pkg[!grepl("/", pkg)]
  pkg_gh <- pkg[grepl("/", pkg)]
  if (length(pkg_non_gh) > 0) {
    renv::install(pkg_non_gh, prompt = FALSE)
  }
  for (i in seq_along(pkg_gh)) {
    renv::install(pkg_gh[i], prompt = FALSE)
  }
  invisible(TRUE)
}

.projr_renv_restore_update_restore_gh_n <- function(pkg) {
  renv::install(pkg, prompt = FALSE)
}