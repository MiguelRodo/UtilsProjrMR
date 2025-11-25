test_that("projr_install_pak_devel function exists and is callable", {
  # We can't actually test the installation, but we can verify the function exists
  expect_true(is.function(projr_install_pak_devel))
})
