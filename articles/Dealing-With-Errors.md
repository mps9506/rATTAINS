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
#> Error:
#> ! Real HTTP connections are disabled.
#> ! Unregistered request:
#> ℹ GET:  https://api.epa.gov/attains/actions?actionIdentifier=R8-ND-2018-03&summarize=N&returnCountOnly=N   with headers {Accept-Encoding: gzip, deflate, Accept: application/json, text/xml, application/xml, */*, X-API-Key: }
#> 
#> You can stub this request with the following snippet:
#>  stub_request('get', uri = 'https://api.epa.gov/attains/actions?actionIdentifier=R8-ND-2018-03&summarize=N&returnCountOnly=N') %>%
#>      wi_th(
#>        headers = list('Accept-Encoding' = 'gzip, deflate', 'Accept' = 'application/json, text/xml, application/xml, */*', 'X-API-Key' = '')
#>      )
#> 
#> registered request stubs:
#>  GET: https://attains.epa.gov/attains-public%2Fapi%2Factions?actionIdentifier=R8-ND-2018-03&summarize=N&returnCountOnly=N    | to_return:    with status 429
#> 
#> 
#> ============================================================
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

state_summary(organization_id = "SDDENR", reporting_cycle = "2024")
#> Unable to further unnest data, check for nested dataframes.
#> $items
#> # A tibble: 21 × 18
#>    organizationIdentifier organizationName organizationTypeText reportingCycle
#>    <chr>                  <chr>            <chr>                <chr>         
#>  1 SDDENR                 South Dakota     State                2024          
#>  2 SDDENR                 South Dakota     State                2024          
#>  3 SDDENR                 South Dakota     State                2024          
#>  4 SDDENR                 South Dakota     State                2024          
#>  5 SDDENR                 South Dakota     State                2024          
#>  6 SDDENR                 South Dakota     State                2024          
#>  7 SDDENR                 South Dakota     State                2024          
#>  8 SDDENR                 South Dakota     State                2024          
#>  9 SDDENR                 South Dakota     State                2024          
#> 10 SDDENR                 South Dakota     State                2024          
#> # ℹ 11 more rows
#> # ℹ 14 more variables: cycleStatus <chr>, combinedCycles <list>,
#> #   waterTypeCode <chr>, unitsCode <chr>, useName <chr>,
#> #   `Fully Supporting` <dbl>, `Fully Supporting-count` <int>,
#> #   `Insufficient Information` <dbl>, `Insufficient Information-count` <int>,
#> #   `Not Supporting` <dbl>, `Not Supporting-count` <int>, parameters <list>,
#> #   `Not Assessed` <dbl>, `Not Assessed-count` <int>
```

Using `.unnest=FALSE` returns nested columns. The tidyr family of
[`unnest()`](https://tidyr.tidyverse.org/reference/unnest.html)
functions is an easy way to flatten this data:

``` r

df <- state_summary(
  organization_id = "SDDENR",
  reporting_cycle = "2024",
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
#> # A tibble: 108 × 7
#>    parameterGroup                     Cause `Cause-count` Insufficient Informa…¹
#>    <chr>                              <dbl>         <int>                  <dbl>
#>  1 PH/ACIDITY/CAUSTIC CONDITIONS     2.31e3            10                   438.
#>  2 TURBIDITY                        NA                 NA                   608.
#>  3 TEMPERATURE                      NA                 NA                   280.
#>  4 ALGAL GROWTH                      2.61e4            17                  5263.
#>  5 ORGANIC ENRICHMENT/OXYGEN DEPLE…  9.68e2             9                   458.
#>  6 AMMONIA                          NA                 NA                   608.
#>  7 MERCURY                           2.50e4            16                    NA 
#>  8 PH/ACIDITY/CAUSTIC CONDITIONS     9.81e0             2                    NA 
#>  9 MERCURY                           1.25e2             1                    NA 
#> 10 ALGAL GROWTH                      1.56e2             3                    NA 
#> # ℹ 98 more rows
#> # ℹ abbreviated name: ¹​`Insufficient Information`
#> # ℹ 3 more variables: `Insufficient Information-count` <int>,
#> #   `Meeting Criteria` <dbl>, `Meeting Criteria-count` <int>
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
  organization_id = "SDDENR",
  reporting_cycle = "2024",
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
#> # A tibble: 21 × 18
#>    organizationIdentifier organizationName organizationTypeText reportingCycle
#>    <chr>                  <chr>            <chr>                <chr>         
#>  1 SDDENR                 South Dakota     State                2024          
#>  2 SDDENR                 South Dakota     State                2024          
#>  3 SDDENR                 South Dakota     State                2024          
#>  4 SDDENR                 South Dakota     State                2024          
#>  5 SDDENR                 South Dakota     State                2024          
#>  6 SDDENR                 South Dakota     State                2024          
#>  7 SDDENR                 South Dakota     State                2024          
#>  8 SDDENR                 South Dakota     State                2024          
#>  9 SDDENR                 South Dakota     State                2024          
#> 10 SDDENR                 South Dakota     State                2024          
#> # ℹ 11 more rows
#> # ℹ 14 more variables: cycleStatus <chr>, combinedCycles <list>,
#> #   waterTypeCode <chr>, unitsCode <chr>, useName <chr>,
#> #   `Fully Supporting` <dbl>, `Fully Supporting-count` <int>,
#> #   `Insufficient Information` <dbl>, `Insufficient Information-count` <int>,
#> #   `Not Supporting` <dbl>, `Not Supporting-count` <int>, parameters <list>,
#> #   `Not Assessed` <dbl>, `Not Assessed-count` <int>
```
