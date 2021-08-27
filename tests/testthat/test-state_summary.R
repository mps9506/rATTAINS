test_that("state_summary returns expected types and classes", {
  state_cache$delete_all()
  vcr::use_cassette("state_summary_works",
                   { x <- state_summary(organization_id = "TDECWR",
                                       reporting_cycle = "2016")})
  testthat::expect_s3_class(x, "tbl_df")

  ## skips on cran due to API use
  skip_on_cran()
  x <- state_summary(organization_id = "TDECWR",
                     reporting_cycle = "2016",
                     tidy = FALSE)
  testthat::expect_type(x, "character")
})

test_that("state_summary returns expected errors", {
  testthat::expect_error(state_summary(organization_id = "TDECWR",
                                       reporting_cycle = 2016))

  testthat::expect_error(state_summary(),
                         "One of the following arguments must be provided: organization_id")
})
