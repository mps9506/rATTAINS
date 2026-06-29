test_that("state_summary returns expected types and classes", {
  vcr::use_cassette("state_summary_works", {
    x <- state_summary(organization_id = "SDDENR", reporting_cycle = "2024")
  })
  testthat::expect_type(x, "list")
  testthat::expect_s3_class(x$items, "tbl_df")

  vcr::use_cassette("state_summary_unnest_works", {
    x <- state_summary(
      organization_id = "SDDENR",
      reporting_cycle = "2024",
      .unnest = TRUE
    )
  })
  testthat::expect_type(x, "list")
  testthat::expect_s3_class(x$items, "tbl_df")

  vcr::use_cassette("state_summary_chr_works", {
    x <- state_summary(
      organization_id = "SDDENR",
      reporting_cycle = "2024",
      tidy = FALSE
    )
  })
  testthat::expect_type(x, "character")
})

test_that("state_summary returns expected errors", {
  testthat::expect_error(state_summary(
    organization_id = "SDDENR",
    reporting_cycle = 2016
  ))

  testthat::expect_error(
    state_summary(),
    "One of the following arguments must be provided: organization_id"
  )

  skip_on_cran()
  webmockr::enable(quiet = TRUE)
  stub <- webmockr::stub_request(
    "get",
    "https://api.epa.gov/attains/usesStateSummary?organizationId=TDECWR&reportingCycle=2016"
  )
  webmockr::to_return(stub, status = 502)
  testthat::expect_error(state_summary(
    organization_id = "TDECWR",
    reporting_cycle = "2016"
  ))
  webmockr::disable(quiet = TRUE)
})
