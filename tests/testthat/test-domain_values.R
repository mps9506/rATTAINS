test_that("domain_values works", {

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

  skip_on_cran()
  webmockr::enable()
  stub <- webmockr::stub_request("get", "https://attains.epa.gov/attains-public/api/domains?domainName=UseName&context=TCEQMAIN")
  webmockr::to_return(stub, status = 502)
  testthat::expect_error(domain_values(domain_name="UseName",context="TCEQMAIN"))
  webmockr::disable()
})
