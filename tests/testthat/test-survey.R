test_that("survey returns expected types and classes", {

  ## set package option
  rATTAINS_options(cache_downloads = FALSE)
  ## clear any pre-existing cache
  surveys_cache$delete_all()

  vcr::use_cassette("survey_works",
                    {x <- surveys(organization_id="SDDENR")})
  testthat::expect_s3_class(x$documents, "tbl_df")
  testthat::expect_s3_class(x$surveys, "tbl_df")

  vcr::use_cassette("survey_chr_works",
                    {x <- surveys(organization_id="SDDENR",
                                  tidy = FALSE)})
  testthat::expect_type(x, "character")
})

test_that("surveys returns expected errors", {
  expect_error(x <- surveys())
  expect_error(x <- surveys(organization_id = 2))

  skip_on_cran()
  webmockr::enable()
  stub <- webmockr::stub_request("get", "https://attains.epa.gov/attains-public/api/surveys?organizationId=SDDENR")
  webmockr::to_return(stub, status = 502)
  testthat::expect_error(surveys(organization_id="SDDENR"))
  webmockr::disable()
})

test_that("survey cache cache works", {
  skip_on_cran()
  skip_if_offline()
  ## set package option
  rATTAINS_options(cache_downloads = TRUE)

  x <- surveys(organization_id="SDDENR",
               timeout_ms = 20000)
  testthat::expect_message(surveys(organization_id="SDDENR"),
                           "reading cached file from: ")

  y <- surveys(organization_id="SDDENR")
  testthat::expect_equal(x, y)

})
