## Test environments

* GitHub Actions (macos-latest), release 
* GitHub Actions (windows-latest), release 
* GitHub Actions (ubuntu-22.04.2), release, devel 
* R-hub (macos-m1), devel 
* R-hub (windows-latest), devel
* R-hub (ubuntu-latest), devel, patched
* winbuilder (windows), release, devel 

## R CMD check results

0 errors | 0 warnings | 0 note

## Comments

* This submission includes minor fixes to build errors introduced by the 
upstream dependency vcr v2.

## Reverse dependencies

There are currently no downstream dependencies for this package.

## Other comments:

* Examples are wrapped in \donttest{} since they rely on an internet connection
and API that will rate limit when automatically test or run.
