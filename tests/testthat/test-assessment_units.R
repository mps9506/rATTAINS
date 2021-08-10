test_that("assessment_units works", {
  ## should clean cached files before hand
  vcr::use_cassette("assessment_units_works", {
    x <- assessment_units(assessment_unit_identifer = "AL03150201-0107-200")
  })
  testthat::expect_s3_class(x, "tbl_df")

  x <- assessment_units(assessment_unit_identifer = "AL03150201-0107-200", tidy = FALSE)
  testthat::expect_type(x, "character")
})

test_that("assessment_units webservice returns errors", {
  testthat::expect_error(assessment_units(assessment_unit_identifer = 10))
})
