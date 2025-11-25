test_that("projr_rprofile_hpc_renv_setup function exists", {
  expect_true(is.function(projr_rprofile_hpc_renv_setup))
})

test_that("projr_rprofile_renv_repos function exists", {
  expect_true(is.function(projr_rprofile_renv_repos))
})

test_that("projr_rprofile_dev function exists", {
  expect_true(is.function(UtilsProjrMR:::projr_rprofile_dev))
})
