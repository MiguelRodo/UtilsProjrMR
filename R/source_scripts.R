projr_source_scripts_r <- function() {
  for (x in list.files(here::here("R"), pattern = "R$|r$", full.names = TRUE)) {
    source(x)
  }
}
