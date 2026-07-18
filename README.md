
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pkgbootstrap

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/BjarkeHautop/pkgbootstrap/graph/badge.svg)](https://app.codecov.io/gh/BjarkeHautop/pkgbootstrap)
[![R-CMD-check](https://github.com/BjarkeHautop/pkgbootstrap/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/BjarkeHautop/pkgbootstrap/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

pkgbootstrap creates a new R package with an opinionated setup in a
single function call:

- air formatting (`usethis::use_air()`)
- git, pushed to GitHub
- a license (MIT by default; pass any `usethis::use_*_license()` call)
- an Rmd README
- codecov test coverage with an opinionated `codecov.yml`
- spell checking
- `R-CMD-check` and `test-coverage` GitHub Actions workflows
- Dependabot updates for GitHub Actions
- a pkgdown site deployed via GitHub Pages
- a `.pre-commit-config.yaml` with panache and air hooks pinned to their
  latest release, installed with [prek](https://github.com/j178/prek) if
  available

## Installation

You can install the development version of pkgbootstrap like so:

``` r
# install.packages("pak")
pak::pak("BjarkeHautop/pkgbootstrap")
```

## Example

``` r
library(pkgbootstrap)
bootstrap_pkg("~/GitHub/mynewpkg")

# or with a different license/author
bootstrap_pkg(
  "~/GitHub/mynewpkg",
  author_name = "First Last",
  author_email = "first.last@example.com",
  license = usethis::use_gpl3_license()
)
```

Creating the GitHub repository requires a GitHub token that `usethis`
can find; see `usethis::gh_token_help()` if `usethis::use_github()`
fails.
