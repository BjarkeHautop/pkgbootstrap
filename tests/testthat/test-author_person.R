test_that("author_person splits given and family names", {
  p <- author_person("Bjarke Hautop", "bjarke.hautop@gmail.com")
  expect_s3_class(p, "person")
  expect_equal(
    format(p),
    "Bjarke Hautop <bjarke.hautop@gmail.com> [aut, cre]"
  )
})

test_that("author_person puts everything but the last word in given names", {
  p <- author_person("Bjarke Hautop Kristensen", "x@y.com")
  expect_equal(p$given, "Bjarke Hautop")
  expect_equal(p$family, "Kristensen")
})

test_that("author_person handles single-word names", {
  p <- author_person("Bjarke", "x@y.com")
  expect_equal(format(p), "Bjarke <x@y.com> [aut, cre]")
})

test_that("author_person ignores surrounding whitespace", {
  p <- author_person("  Bjarke Hautop  ", "x@y.com")
  expect_equal(format(p), "Bjarke Hautop <x@y.com> [aut, cre]")
})
