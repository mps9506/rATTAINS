test_that("assessments works", {
  ## should clean cached files before hand
  vcr::use_cassette("assessments_works", {
    x <- assessments(organization_id = "SDDENR", probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES")
  })
  testthat::expect_s3_class(x$documents, "tbl_df")
  testthat::expect_s3_class(x$use_assessment, "tbl_df")
  testthat::expect_s3_class(x$parameter_assessment, "tbl_df")

  x <- assessments(organization_id = "SDDENR", probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES", tidy = FALSE)
  testthat::expect_type(x, "character")
})

test_that("assessment webservice returns errors", {
  testthat::expect_error(assessments (organization_id = 10))
})
