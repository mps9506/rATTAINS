## Test environments

* local (Windows), R 4.0.5
* GitHub Actions (macOS), release
* GitHub Actions (windows), release
* GitHub Actions (ubuntu-20.04), release, devel
* win-builder (devel)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

Other comments:

* This is a resubmission that added a link to the the data source in the description field of the DESCRIPTION file as requested.
* Examples are wrapped in \donttest{} since they rely on an internet connection and API that will rate limit when automatically test or run.
