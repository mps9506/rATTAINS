test_that("actions webservice works", {
  ## should clean cached files before hand
  vcr::use_cassette("actions_works", {
    x <- actions(action_id = "R8-ND-2018-03")
  })
  testthat::expect_s3_class(x$documents, "tbl_df")
})

test_that("actions webservice returns errors", {
  testthat::expect_error(actions(action_id = 10))
})
