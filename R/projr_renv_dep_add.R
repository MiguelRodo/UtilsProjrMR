#' @title Adds a package to _dependencies.R file for renv to pick up
#'
#' @description Adds \code{library(<pkg>)} for each
#' package listed. Installs them if they're not already installed.
#'
#' @param pkg Character vector.
#' Packages to add to _dependencies.R, and install
#' if not already installed.
#' Can use "<remote>/<repo>" syntax for installing from
#' (e.g., GitHub) remotes, as long as \code{<repo>} is also
#' the name of the package.
#'
#' @export
projr_renv_dep_add <- function(pkg) {
  # Extract package names from possible remotes
  pkg_names <- sapply(pkg, function(x) sub("^.*/", "", x))
  
  # Identify packages that are not installed
  pkg_to_install <- pkg[
    !sapply(pkg_names, requireNamespace, quietly = TRUE)
  ]
  
  # Install packages that are not installed
  if (length(pkg_to_install) > 0) {
    renv::install(pkg_to_install)
  }
  
  # Read or create _dependencies.R file
  if (file.exists("_dependencies.R")) {
    txt_dep <- readLines("_dependencies.R")
  } else {
    txt_dep <- character()
  }
  
  # Add library calls for each package
  for (x in pkg) {
    pkg_name <- sub("^.*/", "", x)
    txt_add <- paste0("library(", pkg_name, ")")
    if (!txt_add %in% txt_dep) {
      txt_dep <- c(txt_dep, txt_add)
    }
  }
  
  # Write updated dependencies to _dependencies.R
  writeLines(txt_dep, "_dependencies.R")
  invisible(TRUE)
}

#' @title Restore renv Environment with Updates
#'
#' @description Restores the renv environment, with options to update
#' packages from GitHub and Bioconductor, or to install the latest versions.
#'
#' @param restore_non_gh Logical. Whether to restore packages not from GitHub
#' or install the latest version. Default is \code{TRUE}.
#' @param restore_gh Logical. Whether to restore packages from GitHub
#' or install the latest version. Default is \code{TRUE}.
#' @param biocmanager_install Logical.
#' If a Bioconductor package needs to be installed, then 
#' if \code{TRUE} it will use \code{BiocManager::install}, otherwise
#' it will use \code{renv::install("bioc::<package_name>")}.
#' Default is \code{TRUE}.
#'
#' @export
projr_renv_restore_update <- function(restore_non_gh = TRUE,
                                      restore_gh = TRUE,
                                      biocmanager_install = TRUE) {
  package_list <- .projr_renv_lockfile_pkg_get()
  .projr_renv_restore_update_impl(
    package_list,
    restore_non_gh,
    restore_gh,
    biocmanager_install
  )
  invisible(TRUE)
}

.projr_renv_lockfile_pkg_get <- function() {
  renv::activate()
  lockfile_list_pkg <- renv::lockfile_read()$Package
  pkg_vec_regular <- character()
  pkg_vec_bioc <- character()
  pkg_vec_gh <- character()
  
  for (package_name in names(lockfile_list_pkg)) {
    package_info <- lockfile_list_pkg[[package_name]]
    remote_username <- package_info$RemoteUsername
    source <- tolower(package_info$Source)
    
    if (is.null(remote_username)) {
      is_bioc <- grepl("bioc", source)
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
    regular = pkg_vec_regular,
    bioc = pkg_vec_bioc,
    gh = pkg_vec_gh
  )
}

.projr_renv_restore_update_impl <- function(package_list,
                                            restore_non_gh,
                                            restore_gh,
                                            biocmanager_install) {
  .projr_renv_restore_update_actual(
    package_list[["regular"]],
    restore_non_gh,
    biocmanager_install,
    is_bioc = FALSE
  )
  .projr_renv_restore_update_actual(
    package_list[["bioc"]],
    restore_non_gh,
    biocmanager_install,
    is_bioc = TRUE
  )
  .projr_renv_restore_update_actual(
    package_list[["gh"]],
    restore_gh,
    biocmanager_install,
    is_bioc = FALSE
  )
  invisible(TRUE)
}

.projr_renv_restore_update_actual <- function(pkg, restore, biocmanager_install, is_bioc) {
  if (length(pkg) == 0L) {
    return(invisible(FALSE))
  }
  
  # Extract package names from possible remotes
  pkg_names <- sapply(pkg, function(x) sub("^.*/", "", x))
  
  if (restore) {
    # Attempt to restore packages
    renv::restore(packages = pkg_names, transactional = FALSE)
    .projr_renv_restore_remaining(pkg_names)
  } else {
    # Install the latest versions
    .projr_renv_install(pkg, biocmanager_install, is_bioc)
  }
  
  # Install any remaining packages that were not installed
  .projr_renv_install_remaining(pkg, biocmanager_install, is_bioc)
  invisible(TRUE)
}

.projr_renv_restore_remaining <- function(pkg) {
  installed_pkgs <- rownames(installed.packages())
  pkg_remaining <- pkg[!pkg %in% installed_pkgs]
  
  if (length(pkg_remaining) == 0L) {
    return(invisible(FALSE))
  }
  
  for (x in pkg_remaining) {
    if (!requireNamespace(x, quietly = TRUE)) {
      renv::restore(packages = x, transactional = FALSE)
    }
  }
}

.projr_renv_install <- function(pkg, biocmanager_install, is_bioc) {
  if (is_bioc) {
    if (biocmanager_install) {
      BiocManager::install(pkg, update = TRUE, ask = FALSE)
    } else {
      renv::install(paste0("bioc::", pkg), prompt = FALSE)
    }
  } else {
    renv::install(pkg, prompt = FALSE)
  }
}

.projr_renv_install_remaining <- function(pkg, biocmanager_install, is_bioc) {
  installed_pkgs <- rownames(installed.packages())
  pkg_remaining <- pkg[
    !sapply(pkg, function(x) sub("^.*/", "", x)) %in% installed_pkgs
  ]
  
  if (length(pkg_remaining) == 0L) {
    return(invisible(FALSE))
  }
  
  # Attempt to install remaining packages
  .projr_renv_install(pkg_remaining, biocmanager_install, is_bioc)
  
  # Check again for any packages that failed to install
  pkg_still_missing <- pkg_remaining[
    !sapply(pkg_remaining, function(x) {
      requireNamespace(sub("^.*/", "", x), quietly = TRUE)
    })
  ]
  
  if (length(pkg_still_missing) == 0L) {
    return(invisible(TRUE))
  }
  
  # Try installing missing packages individually
  for (x in pkg_still_missing) {
    if (!requireNamespace(sub("^.*/", "", x), quietly = TRUE)) {
      .projr_renv_install(x, biocmanager_install, is_bioc)
    }
  }
}
