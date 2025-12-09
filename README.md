<!-- README.md is generated from README.Rmd. Please edit that file -->

# rATTAINS

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/rATTAINS)](https://cran.r-project.org/package=rATTAINS)
[![rATTAINS status
badge](https://mps9506.r-universe.dev/badges/rATTAINS)](https://mps9506.r-universe.dev)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/mps9506/rATTAINS/workflows/R-CMD-check/badge.svg)](https://github.com/mps9506/rATTAINS/actions)
[![codecov](https://codecov.io/gh/mps9506/rATTAINS/branch/main/graph/badge.svg?token=J45QIKWA8E)](https://app.codecov.io/gh/mps9506/rATTAINS)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5469911.svg)](https://doi.org/10.5281/zenodo.5469911)

<!-- badges: end -->

rATTAINS provides functions for downloading tidy data from the United
States (U.S.) Environmental Protection Agency (EPA)
[ATTAINS](https://www.epa.gov/waterdata/attains) webservice. ATTAINS is
the online system used to track and report Clean Water Act assessments
and Total Maximum Daily Loads (TMDLs) in U.S. surface waters. rATTAINS
facilitates access to the [public information
webservice](https://www.epa.gov/waterdata/get-data-access-public-attains-data)
made available through the EPA.

rATTAINS is on CRAN:

    install.packages('rATTAINS')

Or install the development version from r-universe:

    install.packages('rATTAINS', repos = 'https://mps9506.r-universe.dev')

## Functions and webservices

There are eight user available functions that correspond with the first
eight web services detailed by
[EPA](https://www.epa.gov/sites/default/files/2020-10/documents/attains_how_to_access_web_services_2020-10-28.pdf).
All arguments are case sensitive. By default the functions attempt to
provide flattened “tidy” data as a single or multiple dataframes. By
using the `tidy = FALSE` argument in the function below, the raw JSON
will be read into the session for the user to parse if desired. This can
be useful since some webservices provide different results based on the
query and the tidying process used in rATTAINS might make poor
assumptions in the data flattening process. If the function returns
unexpected results, try parsing the raw JSON string.

-   `state_summary()` provides summary information for assessed uses for
    organizations and by integrated reporting cycle.

-   `huc_12_summary()` provides summary information about impairments,
    actions, and documents for the specified 12-digit HUC (watershed).

-   `actions()` provides a summary of information for particular
    finalized actions (TMDLs and related).

-   `assessments()` provides summary data about the specified assessment
    decisions by waterbody.

-   `plans()` returns a summary of the plans (TMDLs and related) within
    a specified HUC.

-   `domain_values()` returns allowed values in ATTAINS. By default (no
    arguments) the function returns a list of allowed `domain_names`.

-   `assessment_units()` returns a summary of information about the
    specified assessment units.

-   `surveys()` returns results from state statistical survey results in
    ATTAINS.

# Examples:

Get a summary about assessed uses from the Texas Commission on
Environmental Quality:

    library(rATTAINS)
    state_summary(
      organization_id = "TCEQMAIN",
      reporting_cycle = "2020",
      .unnest = FALSE
    )
    #> $items
    #> # A tibble: 31 × 18
    #>    organizationIdentifier organizationName organizationTypeText reportingCycle
    #>    <chr>                  <chr>            <chr>                <chr>         
    #>  1 TCEQMAIN               Texas            State                2020          
    #>  2 TCEQMAIN               Texas            State                2020          
    #>  3 TCEQMAIN               Texas            State                2020          
    #>  4 TCEQMAIN               Texas            State                2020          
    #>  5 TCEQMAIN               Texas            State                2020          
    #>  6 TCEQMAIN               Texas            State                2020          
    #>  7 TCEQMAIN               Texas            State                2020          
    #>  8 TCEQMAIN               Texas            State                2020          
    #>  9 TCEQMAIN               Texas            State                2020          
    #> 10 TCEQMAIN               Texas            State                2020          
    #> # ℹ 21 more rows
    #> # ℹ 14 more variables: cycleStatus <chr>, combinedCycles <list>,
    #> #   waterTypeCode <chr>, unitsCode <chr>, useName <chr>,
    #> #   `Fully Supporting` <dbl>, `Fully Supporting-count` <int>,
    #> #   `Insufficient Information` <dbl>, `Insufficient Information-count` <int>,
    #> #   `Not Assessed` <dbl>, `Not Assessed-count` <int>, `Not Supporting` <dbl>,
    #> #   `Not Supporting-count` <int>, parameters <list>

Get a summary about assessed uses, parameters and plans in a HUC12:

    df <- huc12_summary(huc = "020700100204", .unnest = FALSE)

    tidyr::unnest(df, items) |>
      tidyr::unnest(summaryByUseGroup)
    #> # A tibble: 4 × 24
    #>   huc12        assessmentUnitCount totalCatchmentAreaSqMi totalHucAreaSqMi
    #>   <chr>                      <int>                  <dbl>            <dbl>
    #> 1 020700100204                  18                   46.1             46.2
    #> 2 020700100204                  18                   46.1             46.2
    #> 3 020700100204                  18                   46.1             46.2
    #> 4 020700100204                  18                   46.1             46.2
    #> # ℹ 20 more variables: assessedCatchmentAreaSqMi <dbl>,
    #> #   assessedCatchmentAreaPercent <dbl>, assessedGoodCatchmentAreaSqMi <int>,
    #> #   assessedGoodCatchmentAreaPercent <int>,
    #> #   assessedUnknownCatchmentAreaSqMi <int>,
    #> #   assessedUnknownCatchmentAreaPercent <int>,
    #> #   containImpairedWatersCatchmentAreaSqMi <dbl>,
    #> #   containImpairedWatersCatchmentAreaPercent <dbl>, …

    tidyr::unnest(df, items) |>
      tidyr::unnest(summaryByParameterImpairments, names_repair = "minimal")
    #> # A tibble: 16 × 26
    #>    huc12        assessmentUnitCount totalCatchmentAreaSqMi totalHucAreaSqMi
    #>    <chr>                      <int>                  <dbl>            <dbl>
    #>  1 020700100204                  18                   46.1             46.2
    #>  2 020700100204                  18                   46.1             46.2
    #>  3 020700100204                  18                   46.1             46.2
    #>  4 020700100204                  18                   46.1             46.2
    #>  5 020700100204                  18                   46.1             46.2
    #>  6 020700100204                  18                   46.1             46.2
    #>  7 020700100204                  18                   46.1             46.2
    #>  8 020700100204                  18                   46.1             46.2
    #>  9 020700100204                  18                   46.1             46.2
    #> 10 020700100204                  18                   46.1             46.2
    #> 11 020700100204                  18                   46.1             46.2
    #> 12 020700100204                  18                   46.1             46.2
    #> 13 020700100204                  18                   46.1             46.2
    #> 14 020700100204                  18                   46.1             46.2
    #> 15 020700100204                  18                   46.1             46.2
    #> 16 020700100204                  18                   46.1             46.2
    #> # ℹ 22 more variables: assessedCatchmentAreaSqMi <dbl>,
    #> #   assessedCatchmentAreaPercent <dbl>, assessedGoodCatchmentAreaSqMi <int>,
    #> #   assessedGoodCatchmentAreaPercent <int>,
    #> #   assessedUnknownCatchmentAreaSqMi <int>,
    #> #   assessedUnknownCatchmentAreaPercent <int>,
    #> #   containImpairedWatersCatchmentAreaSqMi <dbl>,
    #> #   containImpairedWatersCatchmentAreaPercent <dbl>, …

    tidyr::unnest(df, items) |>
      tidyr::unnest(summaryRestorationPlans, names_repair = "minimal")
    #> # A tibble: 1 × 26
    #>   huc12        assessmentUnitCount totalCatchmentAreaSqMi totalHucAreaSqMi
    #>   <chr>                      <int>                  <dbl>            <dbl>
    #> 1 020700100204                  18                   46.1             46.2
    #> # ℹ 22 more variables: assessedCatchmentAreaSqMi <dbl>,
    #> #   assessedCatchmentAreaPercent <dbl>, assessedGoodCatchmentAreaSqMi <int>,
    #> #   assessedGoodCatchmentAreaPercent <int>,
    #> #   assessedUnknownCatchmentAreaSqMi <int>,
    #> #   assessedUnknownCatchmentAreaPercent <int>,
    #> #   containImpairedWatersCatchmentAreaSqMi <dbl>,
    #> #   containImpairedWatersCatchmentAreaPercent <dbl>, …

Find statistical surveys completed by an organization:

    surveys(organization_id = "SDDENR", .unnest = TRUE)
    #> Unable to further unnest data, check for nested dataframes.
    #> $count
    #> # A tibble: 1 × 1
    #>   count
    #>   <int>
    #> 1     5
    #> 
    #> $items
    #> # A tibble: 5 × 14
    #>   organizationIdentifier organizationName organizationTypeText surveyStatusCode
    #>   <chr>                  <chr>            <chr>                <chr>           
    #> 1 SDDENR                 South Dakota     State                Final           
    #> 2 SDDENR                 South Dakota     State                Final           
    #> 3 SDDENR                 South Dakota     State                Final           
    #> 4 SDDENR                 South Dakota     State                Final           
    #> 5 SDDENR                 South Dakota     State                Final           
    #> # ℹ 10 more variables: year <int>, surveyCommentText <lgl>, documents <list>,
    #> #   waterTypeGroupCode <chr>, subPopulationCode <chr>, unitCode <chr>,
    #> #   size <int>, siteNumber <int>, surveyWaterGroupCommentText <chr>,
    #> #   surveyWaterGroupUseParameters <list>

## Citation

If you use this package in a publication, please cite as:

    citation("rATTAINS")
    #> To cite rATTAINS in publications use:
    #> 
    #>   Schramm, Michael (2021).  rATTAINS: Access EPA 'ATTAINS' Data.  R
    #>   package version 1.0.1 doi:10.5281/zenodo.5469911
    #>   https://CRAN.R-project.org/package=rATTAINS
    #> 
    #> A BibTeX entry for LaTeX users is
    #> 
    #>   @Manual{,
    #>     title = {{rATTAINS}: Access EPA 'ATTAINS' Data},
    #>     author = {Michael Schramm},
    #>     year = {2025},
    #>     url = {https://CRAN.R-project.org/package=rATTAINS},
    #>     doi = {10.5281/zenodo.5469911},
    #>     note = {R package version 1.0.1},
    #>   }
