test_that("huc_12 works", {

  vcr::use_cassette("huc12_works", {
    x_1 <- huc12_summary(huc = "020700100204")
  })
  testthat::expect_s3_class(x_1$huc_summary, "tbl_df")
  testthat::expect_s3_class(x_1$au_summary, "tbl_df")
  testthat::expect_s3_class(x_1$ir_summary, "tbl_df")
  testthat::expect_s3_class(x_1$use_summary, "tbl_df")
  testthat::expect_s3_class(x_1$param_summary, "tbl_df")
  testthat::expect_s3_class(x_1$res_plan_summary, "tbl_df")
  testthat::expect_s3_class(x_1$vision_plan_summary, "tbl_df")

  vcr::use_cassette("huc12_chr_works", {
    x_2 <- huc12_summary(huc = "020700100204", tidy = FALSE)
  })
  testthat::expect_type(x_2, "character")

  # caching seems to cause testing problems on some CRAN platforms
  # test these caching message elsewhere
  # testthat::expect_message(huc12_summary(huc = "020700100204"),
  #                          "reading cached file from: ")
})

test_that("huc_12 retruns errors", {
  expect_error(huc12_summary(huc = 20700100204))
  expect_error(huc12_summary(huc = "020700100204", tidy = "Y"))

  skip_on_cran()
  webmockr::enable()
  stub <- webmockr::stub_request("get", "https://attains.epa.gov/attains-public/api/huc12summary?huc=020700100204")
  webmockr::to_return(stub, status = 502)
  testthat::expect_error(huc12_summary(huc = "020700100204"))
  webmockr::disable()
})
