#' @title Add Packages to `_dependencies.R` for renv
#'
#' @description
#' Adds `library(<pkg>)` calls for each package listed to the `_dependencies.R` file. Installs packages if they are not already installed.
#'
#' @param pkg Character vector.
#' Packages to add to `_dependencies.R`, and install if not already installed.
#' Can use "`<remote>/<repo>`" syntax for installing from remotes (e.g., GitHub), as long as `<repo>` is also the name of the package.
#'
#' @return Invisibly returns `TRUE` upon successful completion.
#'
#' @examples
#' \dontrun{
#' # Add and install CRAN packages
#' projr_renv_dep_add(c("dplyr", "ggplot2"))
#'
#' # Add and install a GitHub package
#' projr_renv_dep_add("hadley/httr")
#' }
#'
#' @export
projr_renv_dep_add <- function(pkg) {
  # Ensure the cli package is available
  .ensure_cli()

  # Extract package names from possible remotes
  pkg_names <- sapply(pkg, function(x) sub("^.*/", "", x))

  # Identify packages that are not installed
  pkg_to_install <- pkg[
    !sapply(pkg_names, requireNamespace, quietly = TRUE)
  ]

  # Install packages that are not installed
  if (length(pkg_to_install) > 0) {
    cli::cli_alert_info("Installing packages: {.pkg {pkg_to_install}}")
    renv::install(pkg_to_install)
  } else {
    cli::cli_alert_info("All specified packages are already installed.")
  }

  # Read or create _dependencies.R file
  if (file.exists("_dependencies.R")) {
    txt_dep <- readLines("_dependencies.R")
    cli::cli_alert_info("Reading existing '_dependencies.R' file.")
  } else {
    txt_dep <- character()
    cli::cli_alert_info("Creating new '_dependencies.R' file.")
  }

  # Add library calls for each package
  new_lib_calls <- character()
  for (x in pkg) {
    pkg_name <- sub("^.*/", "", x)
    txt_add <- paste0("library(", pkg_name, ")")
    if (!txt_add %in% txt_dep) {
      new_lib_calls <- c(new_lib_calls, txt_add)
    }
  }

  if (length(new_lib_calls) > 0) {
    txt_dep <- c(txt_dep, new_lib_calls)
    cli::cli_alert_success("Adding library calls to '_dependencies.R' for packages: {.pkg {pkg_names}}")
  } else {
    cli::cli_alert_info("No new library calls to add to '_dependencies.R'.")
  }

  # Write updated dependencies to _dependencies.R
  writeLines(txt_dep, "_dependencies.R")
  cli::cli_alert_success("'_dependencies.R' has been updated.")
  invisible(TRUE)
}

#' @title Restore or update `renv` lockfile packages
#'
#' @description Restores the renv environment, with options to update
#' packages from GitHub and Bioconductor, or to install the latest versions.
#'
#' `projr_renv_restore` restores packages from the lockfile,
#' and attempts to install the latest available version
#' for packages for which restoration failed.
#' 
#' `projr_renv_update` installs the latest available
#' versions of all packages in the lockfile.
#'
#' `projr_renv_restore_and_update` both restores
#' the lockfile versions and the latest versions.
#'
#' `projr_renv_restore_or_update` is more flexible than
#' `projr_renv_restore` and `projr_renv_install`, as
#' as it may either restore or update, will update packages if restoration
#  failed, and allows restoration or updation to depend on whether the 
#  package is from GitHub or not.
#
#'
#' @param restore_non_gh Logical. Whether to restore packages not from GitHub
#' or install the latest version. Default is \code{TRUE}.
#' @param restore_gh Logical. Whether to restore packages from GitHub
#' or install the latest version. Default is \code{TRUE}.
#' @param biocmanager_install Logical.
#' If a Bioconductor package needs to be installed, then 
#' if \code{TRUE} it will use \code{BiocManager::install}, otherwise
#' it will use \code{renv::install("bioc::<package_name>")}.
#' Default is \code{FALSE}.
#'
#' @export
#' @rdname projr_renv_restore_or_update
projr_renv_restore <- function(github = TRUE,
                               non_github = TRUE,
                               biocmanager_install = FALSE) {
  .check_renv()
  .ensure_cli()

  cli::cli_h1("Starting renv environment restoration")

  package_list <- .projr_renv_lockfile_pkg_get()
  .projr_renv_restore_or_update_impl(
    package_list = package_list,
    non_github = non_github,
    github = github,
    restore = TRUE,
    biocmanager_install = biocmanager_install
  )
  cli::cli_h1("renv environment restoration completed")
  invisible(TRUE)
}

#' @export
#' @rdname projr_renv_restore_or_update
projr_renv_update <- function(github = TRUE,
                              non_github = TRUE,
                              biocmanager_install = FALSE) {
  .check_renv()
  .ensure_cli()

  cli::cli_h1("Starting renv environment restoration")

  package_list <- .projr_renv_lockfile_pkg_get()
  .projr_renv_restore_or_update_impl(
    package_list = package_list,
    non_github = non_github,
    github = github,
    restore = FALSE,
    biocmanager_install = biocmanager_install
  )
  cli::cli_h1("renv environment restoration completed")
  invisible(TRUE)
}

#' @export
#' @rdname projr_renv_restore_and_update
projr_renv_restore_and_update <- function(github = TRUE,
                                          non_github = TRUE,
                                          biocmanager_install = FALSE) {
  projr_renv_restore(github, non_github, biocmanager_install)
  projr_renv_update(github, non_github, biocmanager_install)
}

.check_renv <- function() {
  if (!requireNamespace("renv", quietly = TRUE)) {
    stop("renv is required")
  }
}

.ensure_cli <- function() {
  if (!requireNamespace("cli", quietly = TRUE)) {
    try(renv::install("cli", prompt = FALSE))
  }
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

.projr_renv_restore_or_update_impl <- function(package_list,
                                               github,
                                               non_github,
                                               restore,
                                               biocmanager_install) {
  .projr_renv_restore_or_update_actual_wrapper(
    pkg = package_list[["regular"]],
    act = non_github,
    restore = restore,
    source = "CRAN",
    biocmanager_install = biocmanager_install
  )
  .projr_renv_restore_or_update_actual_wrapper(
    pkg = package_list[["bioc"]],
    act = non_github,
    restore = restore,
    source = "BioConductor",
    biocmanager_install = biocmanager_install
  )
  .projr_renv_restore_or_update_actual_wrapper(
    pkg = package_list[["bioc"]],
    act = github,
    restore = restore,
    source = "GitHub",
    biocmanager_install = biocmanager_install
  )
  invisible(TRUE)
}

.projr_renv_restore_or_update_actual_wrapper <- function(pkg,
                                                         act,
                                                         restore,
                                                         source,
                                                         biocmanager_install) {
  if (act) {
    action <- if (restore) "Restoring" else "Installing latest"
    cli::cli_alert_info(sprintf("%s %s packages.", action, source))

    .projr_renv_restore_update_actual(
      pkg,
      restore,
      biocmanager_install,
      is_bioc = source == "BioConductor"
    )
  } else {
    action <- if (restore) "restoring" else "installing"
    cli::cli_alert_info(sprintf("Skipping %s %s packages.", action, source))
  }
}

.projr_renv_restore_update_actual <- function(pkg, restore, biocmanager_install, is_bioc) {
  if (length(pkg) == 0L) {
    return(invisible(FALSE))
  }

  # Ensure the cli package is available
  .ensure_cli()

  pkg_type <- if (is_bioc) "Bioconductor" else if (all(grepl("/", pkg))) "GitHub" else "CRAN"

  # Extract package names from possible remotes
  pkg_names <- sapply(pkg, function(x) sub("^.*/", "", x))

  if (restore) {
    cli::cli_alert_info("Attempting to restore {pkg_type} packages: {.pkg {pkg_names}}")
    # Attempt to restore packages
    try(renv::restore(packages = pkg_names, transactional = FALSE))
    cli::cli_alert_info("Checking for packages that failed to restore.")
    .projr_renv_restore_remaining(pkg_names)
  } else {
    cli::cli_alert_info("Installing latest versions of {pkg_type} packages: {.pkg {pkg_names}}")
    # Install the latest versions
    .projr_renv_install(pkg, biocmanager_install, is_bioc)
  }

  cli::cli_alert_info("Checking for packages that are still not installed.")
  # Install any remaining packages that were not installed
  .projr_renv_install_remaining(pkg, biocmanager_install, is_bioc)
  invisible(TRUE)
}

.projr_renv_restore_remaining <- function(pkg) {
  # Ensure the cli package is available
  .ensure_cli()

  installed_pkgs <- rownames(installed.packages())
  pkg_remaining <- pkg[!pkg %in% installed_pkgs]

  if (length(pkg_remaining) == 0L) {
    cli::cli_alert_success("All packages restored successfully.")
    return(invisible(FALSE))
  }

  cli::cli_alert_warning("Packages that failed to restore: {.pkg {pkg_remaining}}")
  cli::cli_alert_info("Attempting to restore packages individually.")

  for (x in pkg_remaining) {
    if (!requireNamespace(x, quietly = TRUE)) {
      try(renv::restore(packages = x, transactional = FALSE))
    }
  }
}

.projr_renv_install <- function(pkg, biocmanager_install, is_bioc) {
  # Ensure the cli package is available
  .ensure_cli()

  if (is_bioc) {
    if (biocmanager_install) {
      cli::cli_alert_info("Installing Bioconductor packages using BiocManager: {.pkg {pkg}}")
      try(BiocManager::install(pkg, update = TRUE, ask = FALSE))
    } else {
      cli::cli_alert_info("Installing Bioconductor packages using renv: {.pkg {pkg}}")
      try(renv::install(paste0("bioc::", pkg), prompt = FALSE))
    }
  } else {
    cli::cli_alert_info("Installing packages: {.pkg {pkg}}")
    try(renv::install(pkg, prompt = FALSE))
  }
}

.projr_renv_install_remaining <- function(pkg, biocmanager_install, is_bioc) {
  # Ensure the cli package is available
  .ensure_cli()

  installed_pkgs <- rownames(installed.packages())
  pkg_remaining <- pkg[
    !sapply(pkg, function(x) sub("^.*/", "", x)) %in% installed_pkgs
  ]

  if (length(pkg_remaining) == 0L) {
    cli::cli_alert_success("All packages are installed.")
    return(invisible(FALSE))
  }

  cli::cli_alert_warning("Packages that are still missing: {.pkg {pkg_remaining}}")
  cli::cli_alert_info("Attempting to install remaining packages.")

  # Attempt to install remaining packages
  .projr_renv_install(pkg_remaining, biocmanager_install, is_bioc)

  # Check again for any packages that failed to install
  pkg_still_missing <- pkg_remaining[
    !sapply(pkg_remaining, function(x) {
      requireNamespace(sub("^.*/", "", x), quietly = TRUE)
    })
  ]

  if (length(pkg_still_missing) == 0L) {
    cli::cli_alert_success("All remaining packages installed successfully.")
    return(invisible(TRUE))
  }

  cli::cli_alert_warning("Packages that failed to install: {.pkg {pkg_still_missing}}")
  cli::cli_alert_info("Attempting to install missing packages individually.")

  # Try installing missing packages individually
  for (x in pkg_still_missing) {
    if (!requireNamespace(sub("^.*/", "", x), quietly = TRUE)) {
      .projr_renv_install(x, biocmanager_install, is_bioc)
    }
  }

  # Final check
  pkg_final_missing <- pkg_still_missing[
    !sapply(pkg_still_missing, function(x) {
      requireNamespace(sub("^.*/", "", x), quietly = TRUE)
    })
  ]

  if (length(pkg_final_missing) == 0L) {
    cli::cli_alert_success("All packages installed successfully after individual attempts.")
  } else {
    cli::cli_alert_danger("Some packages failed to install: {.pkg {pkg_final_missing}}")
  }
}
