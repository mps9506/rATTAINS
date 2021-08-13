test_that("survey returns expected types and classes", {
  vcr::use_cassette("survey_works",
                    {x <- surveys(organization_id="SDDENR")})
  testthat::expect_s3_class(x$documents, "tbl_df")
  testthat::expect_s3_class(x$surveys, "tbl_df")

  x <- surveys(organization_id="SDDENR", tidy = FALSE)
  testthat::expect_type(x, "character")
})

test_that("surveys returns expected errors", {
  expect_error(x <- surveys())
  expect_error(x <- surveys(organization_id = 2))
})