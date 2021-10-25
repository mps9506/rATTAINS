test_that("actions webservice works", {

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

  skip_on_cran()
  webmockr::enable()
  stub <- webmockr::stub_request("get", "https://attains.epa.gov/attains-public/api/actions?actionIdentifier=R8-ND-2018-03&summarize=N&returnCountOnly=N")
  webmockr::to_return(stub, status = 502)
  testthat::expect_error(actions(action_id = "R8-ND-2018-03"))
  webmockr::disable()
})


