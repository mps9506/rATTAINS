test_that("plans works", {
  vcr::use_cassette("plans_works", {
    x <- plans(huc ="020700100103")
  })
  testthat::expect_s3_class(x$plans, "tbl_df")
  testthat::expect_s3_class(x$documents, "tbl_df")
  testthat::expect_s3_class(x$associated_pollutants, "tbl_df")
  testthat::expect_s3_class(x$associated_parameters, "tbl_df")
  testthat::expect_s3_class(x$associated_permits, "tbl_df")

  vcr::use_cassette("plans_summary_works", {
    x <- plans(huc ="020700100103", summarize = TRUE)
  })
  testthat::expect_s3_class(x$plans, "tbl_df")
  testthat::expect_s3_class(x$associated_pollutants, "tbl_df")
  testthat::expect_s3_class(x$associated_parameters, "tbl_df")

  x <- plans(huc = "020700100103", tidy = FALSE)
  testthat::expect_type(x, "character")
})

test_that("plans returns errors", {
  testthat::expect_error(plans(huc ="020700100103", summarize = "Y"))
  testthat::expect_error(plans(huc = 12))
})