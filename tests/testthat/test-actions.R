test_that("actions webservice works", {

  ## set package option
  rATTAINS_options(cache_downloads = FALSE)
  ## clear any pre-existing cache
  actions_cache$delete_all()

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
  webmockr::enable()
  stub <- webmockr::stub_request("get", "https://attains.epa.gov/attains-public/api/actions?actionIdentifier=R8-ND-2018-03&summarize=N&returnCountOnly=N")
  webmockr::to_return(stub, status = 502)
  testthat::expect_error(actions(action_id = "R8-ND-2018-03"))
  webmockr::disable()
})


test_that("actions cache works", {
  skip_on_cran()
  ## set package option
  rATTAINS_options(cache_downloads = TRUE)

  vcr::use_cassette("actions_caching_works", {
    x <- actions(action_id = "R8-ND-2018-03", tidy = FALSE)
  })

  y <- actions(action_id = "R8-ND-2018-03", tidy = FALSE)
  testthat::expect_equal(x, y)

})

test_that("actions cache message works", {
  skip_on_cran()
  ##this should read from file cache
  y <- capture.output(actions(action_id = "R8-ND-2018-03", tidy = FALSE),
                      type = "message")

  testthat::expect_match(y, "reading cached file from: ")
})

