test_that("assessments works", {

  vcr::use_cassette("assessments_works", {
    x_1 <- assessments(organization_id = "SDDENR", probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES")
  })
  testthat::expect_type(x_1, "list")
  purrr::map(x_1, \(x) {testthat::expect_s3_class(x, "tbl_df")})

  vcr::use_cassette("assessments_unnest_works", {
    x_1 <- assessments(organization_id = "SDDENR",
                       probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES",
                       .unnest = FALSE)
  })
  testthat::expect_s3_class(x_1, "tbl_df")

  skip_on_cran()
  vcr::use_cassette("assessments_chr_works", {
    x_2 <- assessments(organization_id = "SDDENR", probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES", tidy = FALSE)
  })
  testthat::expect_type(x_2, "character")

})

test_that("assessment webservice returns errors", {
  testthat::expect_error(assessments(organization_id = 10))

  skip_on_cran()
  webmockr::enable(quiet = TRUE)
  stub <- webmockr::stub_request("get", "https://attains.epa.gov/attains-public/api/assessments?organizationId=SDDENR&probableSource=GRAZING%20IN%20RIPARIAN%20OR%20SHORELINE%20ZONES&returnCountOnly=N&excludeAssessments=N")
  webmockr::to_return(stub, status = 502)
  testthat::expect_error(assessments(organization_id = "SDDENR", probable_source = "GRAZING IN RIPARIAN OR SHORELINE ZONES"))
  webmockr::disable(quiet = TRUE)
})
