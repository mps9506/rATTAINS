test_that("actions webservice works", {

  vcr::use_cassette("actions_works", {
    x_1 <- actions(action_id = "R8-ND-2018-03")
  })
  testthat::expect_s3_class(x_1$documents, "tbl_df")
  testthat::expect_s3_class(x_1$actions, "tbl_df")

  vcr::use_cassette("actions_chr_works", {
    x_2 <- actions(action_id = "R8-ND-2018-03", tidy = FALSE)
  })
  testthat::expect_type(x_2, "character")

})

test_that("actions webservice returns errors", {
  testthat::expect_error(actions(action_id = 10))

  skip_on_cran()
  webmockr::enable(quiet = TRUE)
  stub <- webmockr::stub_request("get", "https://attains.epa.gov/attains-public/api/actions?actionIdentifier=R8-ND-2018-03&summarize=N&returnCountOnly=N")
  webmockr::to_return(stub, status = 502)
  testthat::expect_error(actions(action_id = "R8-ND-2018-03"))
  webmockr::disable(quiet = TRUE)
})
