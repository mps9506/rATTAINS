test_that("state_summary returns expected types and classes", {

  ## set package option
  rATTAINS_options(cache_downloads = FALSE)
  ## clear any pre-existing cache
  state_cache$delete_all()

  vcr::use_cassette("state_summary_works",
                   { x <- state_summary(organization_id = "TDECWR",
                                       reporting_cycle = "2016")})
  testthat::expect_s3_class(x, "tbl_df")

  vcr::use_cassette("state_summary_chr_works",
                    { x <- state_summary(organization_id = "TDECWR",
                                         reporting_cycle = "2016",
                                         tidy = FALSE)})
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

test_that("state_summary cache cache works", {
  skip_on_cran()
  skip_if_offline()
  ## set package option
  rATTAINS_options(cache_downloads = TRUE)

  x <- state_summary(organization_id = "TDECWR",
                     reporting_cycle = "2016",
                     timeout_ms = 20000)
  testthat::expect_message(state_summary(organization_id = "TDECWR",
                                         reporting_cycle = "2016"),
                           "reading cached file from: ")

  y <- state_summary(organization_id = "TDECWR",
                     reporting_cycle = "2016")
  testthat::expect_equal(x, y)

})
