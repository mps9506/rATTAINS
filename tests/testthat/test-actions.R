test_that("actions webservice works", {
  ## should clean cached files before hand
  actions_cache$delete_all()
  vcr::use_cassette("actions_works", {
    x <- actions(action_id = "R8-ND-2018-03")
  })
  testthat::expect_s3_class(x$documents, "tbl_df")
  testthat::expect_s3_class(x$actions, "tbl_df")

  skip_on_cran()
  x <- actions(action_id = "R8-ND-2018-03", tidy = FALSE)
  testthat::expect_type(x, "character")
})

test_that("actions webservice returns errors", {
  testthat::expect_error(actions(action_id = 10))
})
