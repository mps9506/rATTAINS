## Test environments

* GitHub Actions (macos-15.7.2), release 
* GitHub Actions (windows-latest), release 
* GitHub Actions (ubuntu-24.04.3), old-release, release, devel 
* winbuilder (windows), release
* local (ubuntu-24.04) release

## R CMD check results

0 errors | 0 warnings | 0 note

## Comments

* This submission removes the dependency on the tibblify package that is scheduled to be archived.

## Reverse dependencies

There are currently no downstream dependencies for this package.

## Other comments:

* Examples are wrapped in \donttest{} since they rely on an internet connection
and API that will rate limit when automatically test or run.
