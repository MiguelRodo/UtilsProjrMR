test_that("projr_file_ext_r_fix handles directories correctly", {
  # Create a temporary directory for testing
  temp_dir <- tempdir()
  test_r_dir <- file.path(temp_dir, "test_r_dir")
  test_rmd_dir <- file.path(temp_dir, "test_rmd_dir")
  
  # Clean up first if directories exist
  unlink(test_r_dir, recursive = TRUE)
  unlink(test_rmd_dir, recursive = TRUE)
  
  dir.create(test_r_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(test_rmd_dir, recursive = TRUE, showWarnings = FALSE)
  
  # Create test files with lowercase extensions
  file.create(file.path(test_r_dir, "test.r"))
  file.create(file.path(test_rmd_dir, "test.rmd"))
  
  # Run the function
  result <- projr_file_ext_r_fix(dir_r = test_r_dir, dir_rmd = test_rmd_dir)
  
  # Check result

  expect_true(result)
  
  # Check that files were renamed
  expect_true(file.exists(file.path(test_r_dir, "test.R")))
  expect_true(file.exists(file.path(test_rmd_dir, "test.Rmd")))
  
  # Original files should not exist
  expect_false(file.exists(file.path(test_r_dir, "test.r")))
  expect_false(file.exists(file.path(test_rmd_dir, "test.rmd")))
  
  # Clean up
  unlink(test_r_dir, recursive = TRUE)
  unlink(test_rmd_dir, recursive = TRUE)
})

test_that("projr_file_ext_r_fix handles non-existent directories", {
  # Test with non-existent directories
  result <- projr_file_ext_r_fix(
    dir_r = "/nonexistent_directory_xyz",
    dir_rmd = "/another_nonexistent_dir"
  )
  expect_true(result)
})

test_that("projr_file_ext_r_fix doesn't modify already correct extensions", {
  # Create a temporary directory for testing
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "test_correct_ext")
  
  unlink(test_dir, recursive = TRUE)
  dir.create(test_dir, recursive = TRUE, showWarnings = FALSE)
  
  # Create test file with correct extension
  file.create(file.path(test_dir, "correct.R"))
  
  # Run the function
  result <- projr_file_ext_r_fix(dir_r = test_dir, dir_rmd = test_dir)
  
  expect_true(result)
  
  # File should still exist with correct extension
  expect_true(file.exists(file.path(test_dir, "correct.R")))
  
  # Clean up
  unlink(test_dir, recursive = TRUE)
})
