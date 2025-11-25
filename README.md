
<!-- README.md is generated from README.Rmd. Please edit that file -->

# UtilsProjrMR

<!-- badges: start -->
[![R-CMD-check](https://github.com/MiguelRodo/UtilsProjrMR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/MiguelRodo/UtilsProjrMR/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/MiguelRodo/UtilsProjrMR/graph/badge.svg)](https://app.codecov.io/gh/MiguelRodo/UtilsProjrMR)
<!-- badges: end -->

UtilsProjrMR provides utility functions to assist with R project set-up,
particularly when using the [`projr`](https://github.com/SATVILab/projr) package.
It includes helper functions for:

- Project initialization and configuration
- SLURM script generation for HPC environments
- renv package management
- targets pipeline setup
- Common code snippets for plotting and file operations

## Installation

You can install the development version of UtilsProjrMR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("MiguelRodo/UtilsProjrMR")
```

## Usage

### Project Initialization

To assist with project set-up, including configuring `.Rprofile` for
development and installing useful packages:

``` r
library(UtilsProjrMR)
projr_init_extra()
```

### Code Snippets

The package provides several `projr_cat_*` functions that print out
commonly-used code snippets:

- `projr_cat_plot_bg_white()` - Add white background theme to ggplot
- `projr_cat_rsync()` - Rsync command for HPC file transfers
- `projr_cat_slurm_header()` - SLURM batch script header
- `projr_cat_slurm_rmd()` - SLURM script for rendering R Markdown
- `projr_cat_pandoc_image()` - Markdown image syntax
- `projr_cat_source_script_r()` - Code to source all R scripts

### renv Management

Functions to help manage renv lockfiles and packages:

``` r
# Add packages to _dependencies.R and install them
projr_renv_dep_add(c("dplyr", "ggplot2"))

# Restore packages from lockfile
projr_renv_restore()

# Update packages to latest versions
projr_renv_update()
```

### File Operations

``` r
# Fix lowercase .r and .rmd extensions to .R and .Rmd
projr_file_ext_r_fix()

# Source all R scripts in R/ directory
projr_source_script_r()
```

### targets Pipeline

``` r
# Create a new targets pipeline
projr_tar_pipeline_create("my_analysis")

# Activate an existing pipeline
projr_tar_pipeline_activate("my_analysis")
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This package is licensed under the MIT License.
