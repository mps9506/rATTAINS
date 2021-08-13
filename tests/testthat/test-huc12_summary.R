test_that("huc_12 works", {
  vcr::use_cassette("huc12_works", {
    x <- huc12_summary(huc = "020700100204")
  })
  testthat::expect_s3_class(x$huc_summary, "tbl_df")
  testthat::expect_s3_class(x$au_summary, "tbl_df")
  testthat::expect_s3_class(x$ir_summary, "tbl_df")
  testthat::expect_s3_class(x$use_summary, "tbl_df")
  testthat::expect_s3_class(x$param_summary, "tbl_df")
  testthat::expect_s3_class(x$res_plan_summary, "tbl_df")
  testthat::expect_s3_class(x$vision_plan_summary, "tbl_df")

  x <- huc12_summary(huc = "020700100204", tidy = FALSE)
  testthat::expect_type(x, "character")

  testthat::expect_message(huc12_summary(huc = "020700100204"),
                           "reading cached file from: ")
})

test_that("huc_12 retruns errors", {
  expect_error(huc12_summary(huc = 20700100204))
  expect_error(huc12_summary(huc = "020700100204", tidy = "Y"))
})
