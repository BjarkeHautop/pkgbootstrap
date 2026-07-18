test_that("prek_install messages and returns FALSE when prek is missing", {
  withr::local_envvar(PATH = "")
  expect_message(
    result <- prek_install(tempdir()),
    "prek not found on PATH"
  )
  expect_false(result)
})
