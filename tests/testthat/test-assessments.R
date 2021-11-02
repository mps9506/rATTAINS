test_that("assessments works", {

  ## set package option
  rATTAINS_options(cache_downloads = FALSE)
  ## clear any pre-existing cache
  assessments_cache$delete_all()

  vcr::use_cassette("assessments_works", {
    x_1 <- assessments(organization_id = "SDDENR", probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES")
  })
  testthat::expect_s3_class(x_1$documents, "tbl_df")
  testthat::expect_s3_class(x_1$use_assessment, "tbl_df")
  testthat::expect_s3_class(x_1$parameter_assessment, "tbl_df")

  skip_on_cran()
  vcr::use_cassette("assessments_chr_works", {
    x_2 <- assessments(organization_id = "SDDENR", probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES", tidy = FALSE)
  })
  testthat::expect_type(x_2, "character")

})

test_that("assessment webservice returns errors", {
  testthat::expect_error(assessments(organization_id = 10))

  skip_on_cran()
  webmockr::enable()
  stub <- webmockr::stub_request("get", "https://attains.epa.gov/attains-public/api/assessments?organizationId=SDDENR&probableSource=GRAZING%20IN%20RIPARIAN%20OR%20SHORELINE%20ZONES&returnCountOnly=N&excludeAssessments=N")
  webmockr::to_return(stub, status = 502)
  testthat::expect_error(assessments(organization_id = "SDDENR", probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES"))
  webmockr::disable()
})

test_that("assessment cache works", {
  skip_on_cran()
  skip_if_offline()
  ## set package option
  rATTAINS_options(cache_downloads = TRUE)
  ## give some time for api to rest
  Sys.sleep(20)

  x <- assessments(organization_id = "SDDENR",
                   probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES",
                   timeout_ms = 20000)
  testthat::expect_message(assessments(organization_id = "SDDENR", probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES"),
                           "reading cached file from: ")
  y <- assessments(organization_id = "SDDENR", probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES")
  testthat::expect_equal(x, y)

})
