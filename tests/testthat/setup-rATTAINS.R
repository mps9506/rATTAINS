library("vcr") # *Required* as vcr is set up on loading
invisible(vcr::vcr_configure(
  dir = vcr::vcr_test_path("fixtures"),
  write_disk_path = vcr::vcr_test_path("files")
))
vcr::check_cassette_names()
