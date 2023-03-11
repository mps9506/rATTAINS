# rATTAINS (development version)

## Major changes

* all API functions use `tibblify::tibblify()` to converted nested lists to
tibbles. This change will ensure functions return consistent data structures
between web calls. Some functions may return slightly different data structures
compared to previous package versions.
* removes magrittr pipe import/export

## Internal changes

* remove dependency on tidyjson.
* update citation file to use bibentry().
* remove the `write_disk_path` folder used by vcr in the test folder.


# rATTAINS 0.1.4

* fixes for compatibility with tidyselect and prep for purrr 1.0.0 (PR #26 @hadley).
* breaking change - removed caching functionality and dependency on hoardr (archived).

# rATTAINS 0.1.3

* add citation file
* add webmocker to suggests, unit test now test for status codes > 200
* RETRY is used instead of GET to address system timeouts
* Connectivity check and useful messages are included if internet is down

# rATTAINS 0.1.2

* vignette no longer creates an empty file tree when building (issue  #14)

# rATTAINS 0.1.1

* add package option to cache files, defaults to `FALSE`.
* minor fixes to address CRAN checks on various platforms.

# rATTAINS 0.1.0

* Released to CRAN

# rATTAINS 0.0.0.9000

* Added primary functions to access webservice.
* Added a `NEWS.md` file to track changes to the package.
* Created vignettes.
* Created pkgdown site.

