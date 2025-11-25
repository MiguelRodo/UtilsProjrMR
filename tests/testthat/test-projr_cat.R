test_that("projr_cat_plot_bg_white outputs correct ggplot theme code", {
  output <- capture.output(result <- projr_cat_plot_bg_white())
  expect_true(result)
  expect_true(any(grepl("theme\\(", output)))
  expect_true(any(grepl("panel.background", output)))
  expect_true(any(grepl("plot.background", output)))
})

test_that("projr_cat_rsync outputs rsync command", {
  output <- capture.output(result <- projr_cat_rsync())
  expect_true(result)
  expect_true(any(grepl("rsync", output)))
})

test_that("projr_cat_slurm_header outputs SLURM script content", {
  output <- capture.output(result <- projr_cat_slurm_header())
  expect_true(result)
  # Should have some SLURM-related content
  expect_true(length(output) > 0)
})

test_that("projr_cat_slurm_rmd outputs SLURM Rmd script content", {
  output <- capture.output(result <- projr_cat_slurm_rmd())
  expect_true(result)
  expect_true(length(output) > 0)
})

test_that("projr_cat_pandoc_image outputs correct markdown image syntax", {
  # Basic case with just path
  output <- capture.output(projr_cat_pandoc_image("image.png"))
  expect_true(any(grepl("!\\[\\]\\(image.png\\)", output)))
  
  # With caption
  output <- capture.output(projr_cat_pandoc_image("image.png", caption = "My Caption"))
  expect_true(any(grepl("!\\[My Caption\\]\\(image.png\\)", output)))
  
  # With args
  output <- capture.output(projr_cat_pandoc_image("image.png", args = "width=50%"))
  expect_true(any(grepl("\\{width=50%\\}", output)))
  
  # With both caption and args
  output <- capture.output(projr_cat_pandoc_image("image.png", caption = "Test", args = "height=100px"))
  expect_true(any(grepl("!\\[Test\\]", output)))
  expect_true(any(grepl("\\{height=100px\\}", output)))
})
