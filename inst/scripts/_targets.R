# _targets.R file
library(targets)
for (x in list.files(here::here("R"), pattern = "R$|r$", full.names = TRUE)) {
  source(x)
}
targets::tar_option_set(
  # attach packages in targets
  packages = c("ggplot2", "tibble", "projr")
)
list(

  # specify _projr directories
  # ------------------
  tar_target(
    dir_data_raw, projr_dir_get("data-raw"),
    cue = tar_cue(mode = "always")
  ),
  tar_target(
    dir_cache, projr_dir_get("cache"),
    cue = tar_cue(mode = "always")
  ),
  tar_target(
    dir_output, projr_dir_get("output"),
    cue = tar_cue(mode = "always")
  ),
  tar_target(
    dir_docs, projr_dir_get("docs"),
    cue = tar_cue(mode = "always")
  ),

  # do something
  # ------------------
  tar_target(x, {
    1
  })
)
