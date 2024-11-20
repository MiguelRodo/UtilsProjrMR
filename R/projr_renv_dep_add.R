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
#' @param restore_non_gh logical. Wether to restore packages not from GitHub,
#' or install the latest version.
#' Default is `TRUE`.
#' @param restore_gh logical. Whether to restore packages from GitHub,
#' or install the latest version. Default is `TRUE`.
#' @param biocmanager_install logical.
#' If a BioConductor package needs to be installed, then 
#' if TRUE it will use `BiocManager::install`, otherwise
#  it will use `renv::install(bioc::<package_name>)`.
#' Default is `TRUE`.
#' @export
projr_renv_restore_update <- function(restore_non_gh = TRUE,
                                      restore_gh = TRUE,
                                      biocmanager_install = TRUE) {
  package_list <- .projr_renv_lockfile_pkg_get()
  .projr_renv_restore_update_impl(package_list, restore_non_gh, restore_gh)
  invisible(TRUE)
}

.projr_renv_lockfile_pkg_get <- function() {
  renv::activate()
  lockfile_list_pkg <- renv::lockfile_read()$Package
  package_names <- c()
  pkg_vec_regular <- NULL
  pkg_vec_bioc <- NULL
  pkg_vec_gh <- NULL
  for (package_index in seq_along(lockfile_list_pkg)) {
    package_info <- lockfile_list_pkg[[package_index]]
    package_name <- package_info$Package
    remote_username <- package_info$RemoteUsername
    if (is.null(remote_username)) {
      is_bioc <- grepl("bioc", tolower(package_index$Source))
      if (is_bioc) {
        pkg_vec_bioc <- c(pkg_vec_bioc, package_name)
      } else {
        pkg_vec_regular <- c(pkg_vec_regular, package_name)
      }
    } else {
      pkg_vec_gh <- c(pkg_vec_gh, paste0(remote_username, "/", package_name))
    }
  }
  list(
    "regular" = pkg_vec_regular,
    "bioc" = pkg_vec_bioc,
    "gh" = pkg_vec_gh
  )
}

# Renamed for clarity
#' @param biocmanager_install logical.
.projr_renv_restore_update_impl <- function(package_list,
                                            restore_non_gh,
                                            restore_gh,
                                            biocmanager_install) {
   .projr_renv_restore_update_actual(
      package_list[["regular"]], restore_non_gh, FALSE, FALSE
    )
   .projr_renv_restore_update_actual(
      package_list[["bioc"]], restore_non_gh, biocmanager_install, TRUE
    )
   .projr_renv_restore_update_actual(
      package_list[["gh"]], restore_gh, FALSE, FALSE
    )
  invisible(TRUE)
}

.projr_renv_restore_update_actual <- function(pkg, restore, biocmanager_install, is_bioc) {
  if (length(pkg) == 0L) {
    return(invisible(FALSE))
  }
  if (restore) {
    try(renv::restore(packages = sapply(pkg, basename), transactional = FALSE))
    .projr_renv_restore_remaining(sapply(pkg, basename))
  } else {
    .projr_renv_install(pkg, biocmanager_install, is_bioc)
  }
  .projr_renv_install_remaining(pkg, biocmanager_install, is_bioc)
  invisible(TRUE)
}

.projr_renv_restore_remaining <- function(pkg) {
  pkg_remaining <- pkg[!pkg %in% installed.packages()]
  if (is.null(pkg_remaining) || length(pkg_remaining) == 0L) {
    return(invisible(FALSE))
  }
  for (x in pkg_remaining) {
    if (!requireNamespace(x, quietly = TRUE)) {
      renv::restore(packages = x, transactional = FALSE)
    }
  }
}

.projr_renv_install <- function(pkg, biocmanager_install, is_bioc) { 
  tryCatch(
    if (biocmanager_install) {
      BiocManager::install(pkg, update = TRUE)
    } else {
      if (is_bioc) {
        renv::install(paste0("bioc::", pkg), prompt = FALSE)
      } else {
        renv::install(pkg, prompt = FALSE)
      }
    }
  )
}

.projr_renv_install_remaining <- function(pkg, biocmanager_install, is_bioc) {
  pkg_remaining <- pkg[!pkg %in% installed.packages()]
  if (is.null(pkg_remaining) || length(pkg_remaining) == 0L) {
    return(invisible(FALSE))
  }
  .projr_renv_install(pkg_remaining, biocmanager_install, is_bioc)
  for (x in pkg_remaining) {
    if (!requireNamespace(x, quietly = TRUE)) {
      .projr_renv_install(x, biocmanager_install, is_bioc)
    }
  }
}

