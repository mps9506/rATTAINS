test_that("domain_values works", {
  vcr::use_cassette("domains_works", {
    x <- domain_values(domain_name="UseName",context="TDECWR")
  })
  testthat::expect_s3_class(x, "tbl_df")

  x <- domain_values(domain_name="UseName",context="TDECWR",tidy=FALSE)
  testthat::expect_type(x, "character")
})

test_that("domain_values webservice returns errors",{
  testthat::expect_error(domain_values(domain_name = 10))
})
