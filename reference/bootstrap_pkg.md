# Create an opinionated R package

Creates a new package with
[`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html)
and applies an opinionated setup:

## Usage

``` r
bootstrap_pkg(
  path,
  author_name = "Bjarke Hautop Kristensen",
  author_email = "bjarke.hautop@gmail.com",
  license = usethis::use_mit_license(),
  private = FALSE
)
```

## Arguments

- path:

  Path where the new package is created. The last component of the path
  is used as the package name.

- author_name:

  Name of the package author (aut/cre in `Authors@R` and the license
  copyright holder).

- author_email:

  Email of the package author.

- license:

  A call to a usethis license function, e.g.
  [`usethis::use_mit_license()`](https://usethis.r-lib.org/reference/licenses.html)
  or
  [`usethis::use_gpl3_license()`](https://usethis.r-lib.org/reference/licenses.html).

- private:

  Should the GitHub repository be private?

## Value

The path to the new package, invisibly. The new package is left as the
active usethis project and activated with
[`usethis::proj_activate()`](https://usethis.r-lib.org/reference/proj_activate.html).

## Details

- air formatting
  ([`usethis::use_air()`](https://usethis.r-lib.org/reference/use_air.html)),
  plus `panache.toml` and `jarl.toml` configs

- git, pushed to GitHub
  ([`usethis::use_git()`](https://usethis.r-lib.org/reference/use_git.html),
  [`usethis::use_github()`](https://usethis.r-lib.org/reference/use_github.html))

- a license, MIT by default

- an Rmd README
  ([`usethis::use_readme_rmd()`](https://usethis.r-lib.org/reference/use_readme_rmd.html))

- codecov test coverage with an opinionated `codecov.yml`
  ([`usethis::use_coverage()`](https://usethis.r-lib.org/reference/use_coverage.html))

- spell checking
  ([`usethis::use_spell_check()`](https://usethis.r-lib.org/reference/use_spell_check.html))

- `R-CMD-check` and `test-coverage` GitHub Actions workflows
  ([`usethis::use_github_action()`](https://usethis.r-lib.org/reference/use_github_action.html))

- Dependabot updates for GitHub Actions

- a pkgdown site deployed via GitHub Pages
  ([`usethis::use_pkgdown_github_pages()`](https://usethis.r-lib.org/reference/use_pkgdown.html))

- a `.pre-commit-config.yaml` with panache, air and jarl hooks pinned to
  their latest release, installed with
  [prek](https://github.com/j178/prek) if available

It finishes by running the hooks once (letting the formatters fix up the
scaffolded files), re-knitting the README, and committing and pushing
the result.
