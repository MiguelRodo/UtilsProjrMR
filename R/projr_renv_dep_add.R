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

#' @title Restore Renv Environment with Updates
#' @param restore_gh Logical. Whether to restore packages from GitHub.
#' @export
projr_renv_restore_update <- function(restore_gh = TRUE) {
  packages <- .projr_renv_lockfile_pkg_get()
  .projr_renv_restore_update_impl(packages, restore_gh)
  invisible(TRUE)
}

# Renamed for clarity
.projr_renv_restore_update_impl <- function(packages, restore_gh) {
  if (restore_gh) {
    .projr_renv_restore_update_restore_gh(packages)
  } else {
    .projr_renv_install(packages)
  }
  invisible(TRUE)
}

.projr_renv_lockfile_pkg_get <- function() {
  lockfile_list_pkg <- renv::lockfile_read()$Package
  package_names <- c() 
  for (package_index in seq_along(lockfile_list_pkg)) {
    package_info <- lockfile_list_pkg[[package_index]]
    package_name <- package_info$Package
    remote_username <- package_info$RemoteUsername
    if (is.null(remote_username)) {
      package_names <- c(package_name, package_names)
    } else {
      package_names <- c(package_names, paste0(remote_username, "/", package_name))
    }
  }
  package_names
}

.projr_renv_restore_update_restore_gh <- function(pkg) {
  pkg_non_gh <- pkg[!grepl("/", pkg)]
  pkg_gh <- pkg[grepl("/", pkg)]
  if (length(pkg_non_gh) > 0) {
    .projr_renv_install(pkg_non_gh)
  }
  for (i in seq_along(pkg_gh)) {
    .projr_renv_restore_ind(pkg_gh[i])
  }
  invisible(TRUE)
}

.projr_renv_install <- function(pkgs) { 
  tryCatch(
    renv::install(pkgs, prompt = FALSE),  # Install all packages at once
    error = function(e) {
      for (pkg in pkgs) {                # If error, install each package individually
        .projr_renv_install_ind(pkg)
      }
    }
  )
}

.projr_renv_install_ind <- function(pkg) {
  tryCatch(
    renv::install(pkg, prompt = FALSE),
    error = function(e) {
      warning(paste0("Failed to install ", pkg))
    }
  )
}

.projr_renv_restore_ind <- function(pkg) {
  tryCatch(
    renv::restore(pkg, prompt = FALSE, transactional = TRUE),
    error = function(e) {
      warning(paste0("Failed to restore ", pkg))
    }
  )
}

.projr_renv_restore_update_restore_gh_n <- function(pkg) {
  renv::install(pkg, prompt = FALSE)
}
