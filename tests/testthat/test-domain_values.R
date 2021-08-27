test_that("domain_values works", {
  dv_cache$delete_all()
  vcr::use_cassette("domains_works", {
    x <- domain_values(domain_name="UseName",context="TCEQMAIN")
  })
  testthat::expect_s3_class(x, "tbl_df")
})

test_that("domain_values single argument works", {
  vcr::use_cassette("single_domain", {
    x <- domain_values(domain_name="OrgStateCode",tidy=FALSE)
  })
  testthat::expect_type(x, "character")
})

test_that("domain_values webservice returns errors",{
  testthat::expect_error(domain_values(domain_name = 10))
})
