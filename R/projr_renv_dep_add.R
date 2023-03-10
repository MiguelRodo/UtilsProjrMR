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
