## Test environments

* GitHub Actions (macos-monterey), release 
* GitHub Actions (windows), release 
* GitHub Actions (ubuntu-22.04), release, devel 
* R-hub (macos-highsierra-release-cran), r-release 
* R-hub (debian-gcc-devel), r-devel 
* R-hub (windows-x86_64-patched), r-patched

## R CMD check results

0 errors | 0 warnings | 0 note

## Comments

* This submission ensures API functions return consistent data structures
between different web API calls.

## Reverse dependencies

There are currently no downstream dependencies for this package.

## Other comments:

* Examples are wrapped in \donttest{} since they rely on an internet connection
and API that will rate limit when automatically test or run.
