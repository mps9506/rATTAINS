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

* This release fixes the 'Additional issues' note I was emailed about. Empty directory trees are no long created when building the vignette.

Other comments:

* Examples are wrapped in \donttest{} since they rely on an internet connection and API that will rate limit when automatically test or run.
