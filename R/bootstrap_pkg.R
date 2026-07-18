#' Create an opinionated R package
#'
#' Creates a new package with [usethis::create_package()] and applies an
#' opinionated setup:
#'
#' * air formatting ([usethis::use_air()])
#' * git, pushed to GitHub ([usethis::use_git()], [usethis::use_github()])
#' * a license, MIT by default
#' * an Rmd README ([usethis::use_readme_rmd()])
#' * codecov test coverage with an opinionated `codecov.yml`
#'   ([usethis::use_coverage()])
#' * spell checking ([usethis::use_spell_check()])
#' * `R-CMD-check` and `test-coverage` GitHub Actions workflows
#'   ([usethis::use_github_action()])
#' * Dependabot updates for GitHub Actions
#' * a pkgdown site deployed via GitHub Pages
#'   ([usethis::use_pkgdown_github_pages()])
#' * a `.pre-commit-config.yaml` with panache and air hooks pinned to their
#'   latest release, installed with [prek](https://github.com/j178/prek) if
#'   available
#'
#' @param path Path where the new package is created. The last component of
#'   the path is used as the package name.
#' @param author_name Name of the package author (aut/cre in `Authors@R` and
#'   the license copyright holder).
#' @param author_email Email of the package author.
#' @param license A call to a usethis license function, e.g.
#'   `usethis::use_mit_license()` or `usethis::use_gpl3_license()`.
#' @param private Should the GitHub repository be private?
#'
#' @return The path to the new package, invisibly.
#' @export
bootstrap_pkg <- function(
  path,
  author_name = "Bjarke Hautop Kristensen",
  author_email = "bjarke.hautop@gmail.com",
  license = usethis::use_mit_license(),
  private = FALSE
) {
  usethis::create_package(
    path,
    fields = list("Authors@R" = author_person(author_name, author_email)),
    open = FALSE
  )
  usethis::local_project(path, force = TRUE)
  path <- usethis::proj_get()

  usethis::use_air()

  usethis::use_git()

  # lazily evaluated here, with the new package as the active project
  force(license)

  # before the README and badges exist, so update_wordlist() finds no new
  # words and does not prompt; the final update_wordlist() below picks them up
  usethis::use_spell_check()

  usethis::use_readme_rmd(open = FALSE)

  usethis::use_github(private = private)

  usethis::use_coverage("codecov")
  usethis::use_template(
    "codecov.yml",
    save_as = "codecov.yml",
    package = "pkgbootstrap"
  )

  usethis::use_github_action("check-standard")
  usethis::use_github_action("test-coverage")

  usethis::use_template(
    "dependabot.yml",
    save_as = ".github/dependabot.yml",
    package = "pkgbootstrap"
  )

  usethis::use_pkgdown_github_pages()

  usethis::use_template(
    "pre-commit-config.yaml",
    save_as = ".pre-commit-config.yaml",
    data = list(
      panache_rev = latest_github_tag(
        "jolars",
        "panache-pre-commit",
        "v2.61.0"
      ),
      air_rev = latest_github_tag("posit-dev", "air-pre-commit", "0.10.0")
    ),
    package = "pkgbootstrap"
  )
  usethis::use_build_ignore(".pre-commit-config.yaml")

  spelling::update_wordlist(pkg = path, confirm = FALSE)

  prek_install(path)

  invisible(path)
}

author_person <- function(name, email) {
  parts <- strsplit(trimws(name), "\\s+")[[1]]
  if (length(parts) == 1) {
    given <- parts
    family <- NULL
  } else {
    given <- paste(parts[-length(parts)], collapse = " ")
    family <- parts[length(parts)]
  }
  utils::person(given, family, email = email, role = c("aut", "cre"))
}

# Latest release tag of a GitHub repo, falling back to the newest plain tag
# for repos without releases, then to `fallback` if GitHub can't be reached
latest_github_tag <- function(owner, repo, fallback) {
  tag <- tryCatch(
    gh::gh(
      "GET /repos/{owner}/{repo}/releases/latest",
      owner = owner,
      repo = repo
    )$tag_name,
    error = function(e) {
      tryCatch(
        gh::gh(
          "GET /repos/{owner}/{repo}/tags",
          owner = owner,
          repo = repo,
          per_page = 1
        )[[1]]$name,
        error = function(e) NULL
      )
    }
  )
  if (is.null(tag)) {
    message(
      "Could not look up the latest tag of ",
      owner,
      "/",
      repo,
      "; using ",
      fallback,
      "."
    )
    return(fallback)
  }
  tag
}

prek_install <- function(path) {
  if (!nzchar(Sys.which("prek"))) {
    message(
      "prek not found on PATH; install it and run `prek install` ",
      "in the package directory to activate the pre-commit hooks."
    )
    return(invisible(FALSE))
  }
  old <- setwd(path)
  on.exit(setwd(old), add = TRUE)
  status <- system2("prek", "install")
  invisible(status == 0)
}
