test_that("assessments works", {
  ## should clean cached files before hand
  vcr::use_cassette("assessments_works", {
    x <- assessments(organization_id = "SDDENR", probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES")
  })
  testthat::expect_s3_class(x$documents, "tbl_df")
  testthat::expect_s3_class(x$use_assessment, "tbl_df")
  testthat::expect_s3_class(x$parameter_assessment, "tbl_df")
})
