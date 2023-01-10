## Test environments

* local (Windows), R 4.2.1
* GitHub Actions (macOS), release
* GitHub Actions (windows), release
* GitHub Actions (ubuntu-20.04), release, devel
* R-hub (macos-highsierra-release-cran), r-release
* R-hub (debian-gcc-devel), r-devel
* R-hub (windows-x86_64-patched), r-patched

## R CMD check results

0 errors | 0 warnings | 0 note

## Comments

* This submission primarily addresses breaking changes from upstream 
  dependencies (tidyselect, purrr, and tidyjson).
* This also removes dependency on the hoardr package (archived by maintainer) 
  and functions for caching to ensure future compatibility with CRAN policies.

## Reverse dependencies

There are currently no downstream dependencies for this package.

## Other comments:

* Examples are wrapped in \donttest{} since they rely on an internet connection 
  and API that will rate limit when automatically test or run.
