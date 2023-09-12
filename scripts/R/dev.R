if (requireNamespace("projr", quietly = TRUE)) {
  library(projr)
}
if (requireNamespace("tibble", quietly = TRUE)) {
  library(tibble)
}
if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)
  sv <- function(fn = "p.pdf", width = 10, height = 10, ...) {
    ggplot2::ggsave(
      filename = projr::projr_path_get("cache", fn),
      units = "cm", width = width, height = height, ...
    )
  }
}
