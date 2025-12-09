# rATTAINS 1.1.0

## Major change
 
This release removes the tibblify dependency. Some endpoints may return 
slightly different lists or incompletely unnested dataframes. We suggest 
using the `.unnest = FALSE` argument and to tidy the dataframes using 
your prefered data rectangling packages (tidyr, data.table, etc.) for the
best consistency across version types.

## Internal changes

* remove tibblify dependency (fixes [#39](https://github.com/mps9506/rATTAINS/issues/39))


# rATTAINS 1.0.1

## Minor changes

* updates for compatibility with vcr v2 (PR #37 @hadley).

# rATTAINS 1.0.0

## Major changes

This major release stabilizes the data structure returned by the functions
calling the ATTAINS API. There might be some breaking changes due to changes
in some column names and nested structure of the data. Unless there are major
changes in the data returned by ATTAINS, my goal is for the current data column
names and structure to stay consistent from this release forward.

* all API functions use `tibblify::tibblify()` to converted nested lists to
tibbles. This change will ensure functions return consistent data structures
between web calls. Some functions may return slightly different data structures
compared to previous package versions (fixes #25, #31).
* added the `.unnest` argument to most functions that return API results. It
defaults to `TRUE` to preserve backwards compatibility. If `FALSE`, results will
be returned in the nest structure provided by ATTAINS.

## Internal changes

* remove dependency on tidyjson.
* remove dependency on janitor.
* update citation file to use `bibentry()`.
* removes magrittr pipe import/export.
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

