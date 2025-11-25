test_that("projr_renv_dep_add function exists", {
  expect_true(is.function(projr_renv_dep_add))
})

test_that("projr_renv_restore function exists", {
  expect_true(is.function(projr_renv_restore))
})

test_that("projr_renv_update function exists", {
  expect_true(is.function(projr_renv_update))
})

test_that("projr_renv_restore_and_update function exists", {
  expect_true(is.function(projr_renv_restore_and_update))
})

test_that(".ensure_cli helper exists", {
  expect_true(is.function(UtilsProjrMR:::.ensure_cli))
})

test_that(".check_renv helper exists", {
  expect_true(is.function(UtilsProjrMR:::.check_renv))
})
