local_package <- function(env = parent.frame()) {
  dir <- withr::local_tempdir(.local_envir = env)
  path <- file.path(dir, "scaffoldtest")
  withr::local_options(usethis.quiet = TRUE, .local_envir = env)
  usethis::create_package(path, open = FALSE)
  usethis::local_project(path, force = TRUE, .local_envir = env)
  usethis::proj_get()
}

test_that("pre-commit template renders the hook revisions", {
  path <- local_package()
  usethis::use_template(
    "pre-commit-config.yaml",
    save_as = ".pre-commit-config.yaml",
    data = list(panache_rev = "vP", air_rev = "vA", jarl_rev = "vJ"),
    package = "pkgbootstrap"
  )
  config <- readLines(file.path(path, ".pre-commit-config.yaml"))
  expect_in(c("    rev: vP", "    rev: vA", "    rev: vJ"), config)
  expect_true(any(grepl("id: readme-rmd-rendered", config)))
  expect_true(any(grepl("id: needs-roxygenize", config)))
  expect_true(any(grepl("id: jarl-check", config)))
})

test_that("panache.toml template routes R linting and formatting", {
  path <- local_package()
  usethis::use_template(
    "panache.toml",
    save_as = "panache.toml",
    package = "pkgbootstrap"
  )
  toml <- readLines(file.path(path, "panache.toml"))
  expect_in(c('r = "jarl"', 'r = "air"'), toml)
})

test_that("codecov and dependabot templates render verbatim", {
  path <- local_package()
  usethis::use_template(
    "codecov.yml",
    save_as = "codecov.yml",
    package = "pkgbootstrap"
  )
  usethis::use_directory(".github")
  usethis::use_template(
    "dependabot.yml",
    save_as = ".github/dependabot.yml",
    package = "pkgbootstrap"
  )
  expect_true(any(grepl(
    "informational: true",
    readLines(file.path(path, "codecov.yml"))
  )))
  expect_true(any(grepl(
    "package-ecosystem: \"github-actions\"",
    readLines(file.path(path, ".github/dependabot.yml"))
  )))
})
