test_that("assessment_units works", {

  vcr::use_cassette("assessment_units_works", {
    x <- assessment_units(assessment_unit_identifer = "AL03150201-0107-200")
  })
  testthat::expect_s3_class(x, "tbl_df")

  skip_on_cran()
  x <- assessment_units(assessment_unit_identifer = "AL03150201-0107-200", tidy = FALSE)
  testthat::expect_type(x, "character")
})

test_that("assessment_units webservice returns errors", {
  testthat::expect_error(assessment_units(assessment_unit_identifer = 10))

  skip_on_cran()
  webmockr::enable()
  stub <- webmockr::stub_request("get", "https://attains.epa.gov/attains-public/api/assessmentUnits?assessmentUnitIdentifier=AL03150201-0107-200")
  webmockr::to_return(stub, status = 502)
  testthat::expect_error(assessment_units(assessment_unit_identifer = "AL03150201-0107-200"))
  webmockr::disable()
})
