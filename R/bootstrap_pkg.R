#' Create an opinionated R package
#'
#' Creates a new package with [usethis::create_package()] and applies an
#' opinionated setup:
#'
#' * air formatting ([usethis::use_air()]), plus `panache.toml` and
#'   `jarl.toml` configs
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
#' * a `.pre-commit-config.yaml` with panache, air and jarl hooks pinned to
#'   their latest release, installed with
#'   [prek](https://github.com/j178/prek) if available
#'
#' It finishes by running the hooks once (letting the formatters fix up the
#' scaffolded files), re-knitting the README, and committing and pushing the
#' result.
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
#' @return The path to the new package, invisibly. The new package is left as
#'   the active usethis project and activated with [usethis::proj_activate()].
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
  usethis::proj_set(path, force = TRUE)
  path <- usethis::proj_get()
  # some usethis helpers (e.g. use_readme_rmd()) validate the working
  # directory, not the active project; proj_activate() at the end keeps it here
  setwd(path)

  usethis::use_air()

  usethis::use_template(
    "panache.toml",
    save_as = "panache.toml",
    package = "pkgbootstrap"
  )
  # empty placeholder config, like use_air()'s air.toml; use_template()
  # cannot write empty files
  file.create(file.path(path, "jarl.toml"))
  usethis::use_build_ignore(c("panache.toml", "jarl.toml"))

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

  usethis::use_directory(".github", ignore = TRUE)
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
      air_rev = latest_github_tag("posit-dev", "air-pre-commit", "0.10.0"),
      jarl_rev = latest_github_tag("etiennebacher", "jarl-pre-commit", "0.5.0")
    ),
    package = "pkgbootstrap"
  )
  usethis::use_build_ignore(".pre-commit-config.yaml")

  invisible(utils::capture.output(suppressMessages(
    spelling::update_wordlist(pkg = path, confirm = FALSE)
  )))

  prek_install(path)

  commit_scaffolding(path)

  usethis::proj_activate(path)

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

# Run the hooks once so the formatters fix up the scaffolded files, re-knit
# the README, then commit (the hooks run again and should pass) and push
commit_scaffolding <- function(path) {
  old <- setwd(path)
  on.exit(setwd(old), add = TRUE)

  system2("git", c("add", "-A"))
  if (nzchar(Sys.which("prek"))) {
    # a nonzero exit here usually just means the formatters modified files
    system2("prek", "run")
  }

  devtools::build_readme(path)

  system2("git", c("add", "-A"))
  msg <- paste0(
    "Generate pkg with pkgbootstrap v",
    utils::packageVersion("pkgbootstrap")
  )
  status <- system2("git", c("commit", "-m", shQuote(msg)))
  if (status != 0) {
    message("Commit failed; inspect the hook output above and commit manually.")
    return(invisible(FALSE))
  }

  has_remote <- length(system2("git", "remote", stdout = TRUE)) > 0
  if (has_remote) {
    system2("git", "push")
  }
  invisible(TRUE)
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
  # --overwrite replaces the README-freshness hook that use_readme_rmd()
  # installed, instead of keeping it around as a noisy legacy hook
  status <- system2("prek", c("install", "--overwrite"))
  invisible(status == 0)
}
