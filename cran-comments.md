## Test environments

* GitHub Actions (macos-15.7.7), release 
* GitHub Actions (windows-latest), release 
* GitHub Actions (ubuntu-24.04.4), old-rel-1, release, devel 
* winbuilder (windows), release
* local (ubuntu-24.04) release

## R CMD check results

0 errors | 0 warnings | 0 note

## Comments

* This submission fixes the error on current CRAN checks caused by the updated URLs and mandatory API keys.

## Reverse dependencies

There are currently no downstream dependencies for this package.

## Other comments:

* Examples are wrapped in \donttest{} since they rely on an internet connection
and API keys.
