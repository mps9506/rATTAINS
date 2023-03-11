library("vcr") # *Required* as vcr is set up on loading
invisible(vcr::vcr_configure(
  ## this creates an absolute path, probably need a relative path
  dir = vcr::vcr_test_path("fixtures"),
  ## dir = "../fixtures",
  ## this creates an absolute path
  ## write_disk_path = vcr::vcr_test_path("files")
  ## probably want a relative path
  ## write_disk_path = "../files"
))
vcr::check_cassette_names()
