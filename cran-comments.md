## Test environments

* local (Windows), R 4.0.5
* GitHub Actions (macOS), release
* GitHub Actions (windows), release
* GitHub Actions (ubuntu-20.04), release, devel
* win-builder (devel)

## R CMD check results

0 errors | 0 warnings | 0 note

* This release addresses the CRAN check errors introduced on the initial release. Additional checks have been run on the rhub platforms that resulted in failed checks on the initial release.

Other comments:

* Examples are wrapped in \donttest{} since they rely on an internet connection and API that will rate limit when automatically test or run.
