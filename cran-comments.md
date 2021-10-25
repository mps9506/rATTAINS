## Test environments

* local (Windows), R 4.0.5
* GitHub Actions (macOS), release
* GitHub Actions (windows), release
* GitHub Actions (ubuntu-20.04), release, devel
* R-hub (macos-highsierra-release-cran), r-release
* R-hub (debian-gcc-devel), r-devel
* R-hub (windows-x86_64-patched), r-patched

## R CMD check results

0 errors | 0 warnings | 0 note

* This release fixes problems CRAN emailed me about providing informative messages
  when internet resources are not available. The unit tests are using recorded HTTP
  responses so the test failure was a legitimate failure as the tests are not actually
  trying to request outside resources. 

Other comments:

* Examples are wrapped in \donttest{} since they rely on an internet connection and API that will rate limit when automatically test or run.
