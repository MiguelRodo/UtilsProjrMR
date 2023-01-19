#' @title Print out code to add white background to a plot
#'
#' @export
projr_cat_plot_bg_white <- function() {
  cat(
    " +", "\n",
    "theme(", "\n",
    '  panel.background = element_rect(fill = "white"),', "\n",
    '  plot.background = element_rect(fill = "white")', "\n",
    ")"
  )
  invisible(TRUE)
}

#' @title Print out code to use rsync between HPC and local
#'
#' @export
projr_cat_rsync <- function() {
  cat("rsync -avzh rdxmig002@hpc.uct.ac.za:<server_path> <host_path>")
  invisible(TRUE)
}

#' @title Print out top matter for a SLURM bash scripts
#' @export
projr_cat_slurm_header <- function() {
  txt <- readLines(
    system.file("scripts", "slurm_header.sh", package = "UtilsProjrMR")
  )
  cat(txt, sep = "\n")
  invisible(TRUE)
}

#' @title Print out top matter for a SLURM bash scripts
#' @export
projr_cat_slurm_rmd <- function() {
  txt <- readLines(
    system.file("scripts", "slurm_rmd.sh", package = "UtilsProjrMR")
  )
  cat(txt, sep = "\n")
  invisible(TRUE)
}

#' @title Print out code to source scripts
#' @export
projr_cat_source_script_r <- function() {
  if (!requireNamespace("here", quietly = TRUE)) {
    renv::install("here")
  }
  cat(
    'for (x in list.files(here::here("R"), pattern = "R$|r$", full.names = TRUE)) {',
    "  source(x)",
    "}",
    sep = "\n"
  )
}
