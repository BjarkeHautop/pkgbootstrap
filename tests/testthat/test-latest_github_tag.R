test_that("latest_github_tag falls back with a message when GitHub is unreachable", {
  local_mocked_bindings(gh = function(...) stop("offline"), .package = "gh")
  expect_message(
    tag <- latest_github_tag("owner", "repo", "v1.2.3"),
    "using v1.2.3"
  )
  expect_equal(tag, "v1.2.3")
})

test_that("latest_github_tag uses the newest plain tag when there are no releases", {
  local_mocked_bindings(
    gh = function(endpoint, ...) {
      if (grepl("releases", endpoint)) {
        stop("404 no releases")
      }
      list(list(name = "v9.9.9"))
    },
    .package = "gh"
  )
  expect_equal(latest_github_tag("owner", "repo", "v1.2.3"), "v9.9.9")
})

test_that("latest_github_tag finds a real release tag", {
  skip_on_cran()
  skip_if_offline("api.github.com")
  tag <- latest_github_tag("posit-dev", "air-pre-commit", "0.10.0")
  expect_match(tag, "^v?[0-9]")
})
