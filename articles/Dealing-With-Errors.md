# Dealing with Errors

``` r
library(rATTAINS)
library(jsonlite)
library(tidyr)
```

There are a number of errors that you might encounter using this
rATTAINS. Here is a list of potential errors and fixes. Feel free to
raise an issue if I missed something.

## Network Connectivity

The following error message likely indicates an issue connecting to the
EPA server:

``` r
state_summary(organization_id = "TCEQMAIN", reporting_cycle = "2022")
```

Potential issues/fixes:

- Check your network connection.
- Check
  [attains.epa.gov](https://mps9506.github.io/rATTAINS/articles/attains.epa.gov).
  If you are able to connect, a warning notice about accessing U.S.
  Government information systems should show in your web browser.
- Occasionally proxy systems used in corporate IT systems cause issues
  with connections (see:
  <https://stackoverflow.com/questions/59796178/r-curlhas-internet-false-even-though-there-are-internet-connection>).
  I’ve tried to account for this in the package, but you might run into
  occasional issues.

## Server Response

The server might also return http code messages. The most common will be
404 or 429. rATTAINS will generally provide a simple message and error
when this is encountered:

``` r
actions(action_id = "R8-ND-2018-03")
#> 
#> Error: parse error: premature EOF
#>                                        
#>                      (right here) ------^
```

Potential issues/fixes:

- Wait until the server is responsive.
- Make less frequent requests.

## Parsing Errors

The default behavior in rATTAINS is to parse JSON data downloaded from
the API to one or more dataframes. These are returned as a single
dataframe or list of dataframes depending on the function. rATTAINS also
tries to flatten the data as much as possible. This design choice
**might** have been a mistake because it can become a source of errors
if the data returned by the API changes or is inconsistent. As of
version 1.0.0 of the package the `.unnest` argument was added to most
functions. By setting `.unnest=FALSE` many of these problems should be
avoided.

Default behavior:

``` r
state_summary(organization_id = "TDECWR", reporting_cycle = "2022")
#> Unable to further unnest data, check for nested dataframes.
#> $items
#> # A tibble: 20 × 18
#>    organizationIdentifier organizationName organizationTypeText reportingCycle
#>    <chr>                  <chr>            <chr>                <chr>         
#>  1 TDECWR                 Tennessee        State                2022          
#>  2 TDECWR                 Tennessee        State                2022          
#>  3 TDECWR                 Tennessee        State                2022          
#>  4 TDECWR                 Tennessee        State                2022          
#>  5 TDECWR                 Tennessee        State                2022          
#>  6 TDECWR                 Tennessee        State                2022          
#>  7 TDECWR                 Tennessee        State                2022          
#>  8 TDECWR                 Tennessee        State                2022          
#>  9 TDECWR                 Tennessee        State                2022          
#> 10 TDECWR                 Tennessee        State                2022          
#> 11 TDECWR                 Tennessee        State                2022          
#> 12 TDECWR                 Tennessee        State                2022          
#> 13 TDECWR                 Tennessee        State                2022          
#> 14 TDECWR                 Tennessee        State                2022          
#> 15 TDECWR                 Tennessee        State                2022          
#> 16 TDECWR                 Tennessee        State                2022          
#> 17 TDECWR                 Tennessee        State                2022          
#> 18 TDECWR                 Tennessee        State                2022          
#> 19 TDECWR                 Tennessee        State                2022          
#> 20 TDECWR                 Tennessee        State                2022          
#> # ℹ 14 more variables: cycleStatus <chr>, combinedCycles <list>,
#> #   waterTypeCode <chr>, unitsCode <chr>, useName <chr>,
#> #   `Fully Supporting` <dbl>, `Fully Supporting-count` <int>,
#> #   `Not Assessed` <dbl>, `Not Assessed-count` <int>, parameters <list>,
#> #   `Not Supporting` <dbl>, `Not Supporting-count` <int>,
#> #   `Insufficient Information` <dbl>, `Insufficient Information-count` <int>
```

Using `.unnest=FALSE` returns nested columns. The tidyr family of
[`unnest()`](https://tidyr.tidyverse.org/reference/unnest.html)
functions is an easy way to flatten this data:

``` r
df <- state_summary(
  organization_id = "TDECWR",
  reporting_cycle = "2022",
  .unnest = FALSE
)

df$items |>
  dplyr::select(parameters) |>
  tidyr::unnest_wider(parameters) |>
  tidyr::unnest(c(
    parameterGroup,
    Cause,
    "Cause-count",
    "Meeting Criteria",
    "Meeting Criteria-count",
    "Insufficient Information",
    "Insufficient Information-count"
  ))
#> # A tibble: 67 × 7
#>    parameterGroup                         Cause `Cause-count` `Meeting Criteria`
#>    <chr>                                  <dbl>         <int>              <dbl>
#>  1 NUTRIENTS                            29134.              3                 NA
#>  2 SALINITY/TOTAL DISSOLVED SOLIDS/CHL…    56.1             1                 NA
#>  3 PH/ACIDITY/CAUSTIC CONDITIONS        23051               1                 NA
#>  4 SALINITY/TOTAL DISSOLVED SOLIDS/CHL…    56.1             1                 NA
#>  5 PH/ACIDITY/CAUSTIC CONDITIONS        23107.              2                 NA
#>  6 ORGANIC ENRICHMENT/OXYGEN DEPLETION   5269.              5                 NA
#>  7 SEDIMENT                              3772.              7                 NA
#>  8 SALINITY/TOTAL DISSOLVED SOLIDS/CHL…    56.1             1                 NA
#>  9 AMMONIA                                 56.1             1                 NA
#> 10 TEMPERATURE                             NA              NA              20459
#> # ℹ 57 more rows
#> # ℹ 3 more variables: `Meeting Criteria-count` <int>,
#> #   `Insufficient Information` <dbl>, `Insufficient Information-count` <int>
```

If the above option doesn’t work, rATTAINS can also provide the raw JSON
data from the API. The
[jsonlite](https://cran.r-project.org/package=jsonlite) 📦 provides
tools to convert JSON to nested lists and tibbles pretty easily. First,
use the `tidy=FALSE` argument to return the unparsed JSON string, then
uses jsonlite to convert that data to a nested list, then use tidyr to
access the nested dataframes!

``` r
raw_data <- state_summary(
  organization_id = "TDECWR",
  reporting_cycle = "2022",
  tidy = FALSE
)

list_data <- jsonlite::fromJSON(
  raw_data,
  simplifyVector = TRUE,
  simplifyDataFrame = TRUE,
  flatten = FALSE
)

df <- tibble::as_tibble(list_data$data)
df |>
  tidyr::unnest(reportingCycles) |>
  tidyr::unnest(waterTypes) |>
  tidyr::unnest(useAttainments)
#> # A tibble: 20 × 18
#>    organizationIdentifier organizationName organizationTypeText reportingCycle
#>    <chr>                  <chr>            <chr>                <chr>         
#>  1 TDECWR                 Tennessee        State                2022          
#>  2 TDECWR                 Tennessee        State                2022          
#>  3 TDECWR                 Tennessee        State                2022          
#>  4 TDECWR                 Tennessee        State                2022          
#>  5 TDECWR                 Tennessee        State                2022          
#>  6 TDECWR                 Tennessee        State                2022          
#>  7 TDECWR                 Tennessee        State                2022          
#>  8 TDECWR                 Tennessee        State                2022          
#>  9 TDECWR                 Tennessee        State                2022          
#> 10 TDECWR                 Tennessee        State                2022          
#> 11 TDECWR                 Tennessee        State                2022          
#> 12 TDECWR                 Tennessee        State                2022          
#> 13 TDECWR                 Tennessee        State                2022          
#> 14 TDECWR                 Tennessee        State                2022          
#> 15 TDECWR                 Tennessee        State                2022          
#> 16 TDECWR                 Tennessee        State                2022          
#> 17 TDECWR                 Tennessee        State                2022          
#> 18 TDECWR                 Tennessee        State                2022          
#> 19 TDECWR                 Tennessee        State                2022          
#> 20 TDECWR                 Tennessee        State                2022          
#> # ℹ 14 more variables: cycleStatus <chr>, combinedCycles <list>,
#> #   waterTypeCode <chr>, unitsCode <chr>, useName <chr>,
#> #   `Fully Supporting` <dbl>, `Fully Supporting-count` <int>,
#> #   `Not Assessed` <dbl>, `Not Assessed-count` <int>, parameters <list>,
#> #   `Not Supporting` <dbl>, `Not Supporting-count` <int>,
#> #   `Insufficient Information` <dbl>, `Insufficient Information-count` <int>
```
