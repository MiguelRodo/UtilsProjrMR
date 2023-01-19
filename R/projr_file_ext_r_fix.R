#' @title Fix R and Rmd file extensions
#'
#' @title In VS Code, R and Rmd files by default
#' have lower-case extensions, which is non-standard and
#' a bit annoying.
#' This fixes that.
#' Installs the \code{here} package if not used already.
#' @param dir_r,dir_rmd character.
#' Paths to directories containing R and Rmd files, respectively
#' @export
projr_file_ext_r_fix <- function(dir_r = here::here("R"),
                                 dir_rmd = here::here()) {
  if (!requireNamespace("here", quietly = TRUE)) {
    install.packages("here")
  }
  if (dir.exists(dir_r)) {
    fn_vec <- list.files(dir_r)
    for (i in seq_along(fn_vec)) {
      x <- fn_vec[i]
      if (!grepl("\\.r", x)) {
        next
      }
      x_new <- gsub("\\.r", ".R", x)
      file.copy(file.path(dir_r, x), file.path(dir_r, x_new))
      file.remove(file.path(dir_r, x))
    }
  }
  if (dir.exists(dir_rmd)) {
    fn_vec <- list.files(dir_rmd)
    for (i in seq_along(fn_vec)) {
      x <- fn_vec[i]
      if (!grepl("\\.rmd", x)) {
        next
      }
      x_new <- gsub("\\.rmd", ".Rmd", x)
      file.copy(file.path(dir_rmd, x), file.path(dir_rmd, x_new))
      file.remove(file.path(dir_rmd, x))
    }
  }
  invisible(TRUE)
}
