# Download Plans and Actions by HUC

Returns information about plans or actions (TMDLs, 4B Actions,
Alternative Actions, Protective Approach Actions) that have been
finalized. This is similar to
[actions](https://mps9506.github.io/rATTAINS/reference/actions.md) but
returns data by HUC code and any assessment units covered by a plan or
action within the specified HUC.

## Usage

``` r
plans(
  huc,
  organization_id = NULL,
  summarize = FALSE,
  tidy = TRUE,
  .unnest = TRUE,
  ...
)
```

## Arguments

- huc:

  (character) Filters the returned actions by 8-digit or higher HUC.
  required

- organization_id:

  (character). Filters the returned actions by those belonging to the
  specified organization. Multiple values can be used. optional

- summarize:

  (logical) If `TRUE` the count of assessment units is returned rather
  than the assessment unit itdentifers for each action. Defaults to
  `FALSE`.

- tidy:

  (logical) `TRUE` (default) the function returns a list of tibbles.
  `FALSE` the function returns the raw JSON string.

- .unnest:

  (logical) `TRUE` (default) the function attempts to unnest data to
  longest format possible. This defaults to `TRUE` for backwards
  compatibility but it is suggested to use `FALSE`.

- ...:

  list of curl options passed to
  [`crul::HttpClient()`](https://docs.ropensci.org/crul/reference/HttpClient.html)

## Value

If `count = TRUE` returns a tibble that summarizes the count of actions
returned by the query. If `count = FALSE` returns a list of tibbles
including documents, use assessment data, and parameters assessment data
identified by the query. If `tidy = FALSE` the raw JSON string is
returned, else the JSON data is parsed and returned as a list of
tibbles.

## Details

`huc` is a required argument. Multiple values are allowed for indicated
arguments and should be included as a comma separated values in the
string (eg. `organization_id="TCEQMAIN,DCOEE"`).

## Note

See
[domain_values](https://mps9506.github.io/rATTAINS/reference/domain_values.md)
to search values that can be queried. As of v1.0 this function no longer
returns the `documents`, `associated_permits`, or `plans` tibbles.

## Examples

``` r
if (FALSE) { # \dontrun{

## Query plans by huc
plans(huc ="020700100103")

## return a JSON string instead of list of tibbles
plans(huc = "020700100103", tidy = FALSE)
} # }
```
