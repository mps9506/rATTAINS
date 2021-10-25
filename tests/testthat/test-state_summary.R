test_that("state_summary returns expected types and classes", {

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

  skip_on_cran()
  webmockr::enable()
  stub <- webmockr::stub_request("get", "https://attains.epa.gov/attains-public/api/usesStateSummary?organizationId=TDECWR&reportingCycle=2016")
  webmockr::to_return(stub, status = 502)
  testthat::expect_error(state_summary(organization_id = "TDECWR",
                                       reporting_cycle = "2016"))
  webmockr::disable()
})
