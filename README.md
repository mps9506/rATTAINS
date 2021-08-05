
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rATTAINS

<!-- badges: start -->

[![R-CMD-check](https://github.com/mps9506/rATTAINS/workflows/R-CMD-check/badge.svg)](https://github.com/mps9506/rATTAINS/actions)
<!-- badges: end -->

Work in progress, probably don’t use.

rATTAINS provides functions for downloading tidy data from the
Environmental Protection Agency (EPA) ATTAINS webservice. ATTAINS is the
online system used to track and report Clean Water Act assessments and
Total Maximum Daily Loads (TMDLs) in US surface waters. rATTAINS
provides access to public information made available through the EPA.

Install from Github

``` r
install.packages("remotes")
remotes::install_github("mps9506/rATTAINS")
```

## Functions and webservices

There are eight user available functions that correspond with the first
eight web services detailed by
[EPA](https://www.epa.gov/sites/default/files/2020-10/documents/attains_how_to_access_web_services_2020-10-28.pdf).
All arguments are case sensitive.

### State Summary

`state_summary()` provides summary information for assessed uses for
organizations and by integrated reporting cycle. The only required
argument is the `organization_id`.

`huc_12_summary()` provides summary information for a 12-digit HUC
(watershed). The only required argument is the 12 digit HUC.

`domain_values()` returns allowed values in ATTAINS. By default (no
arguments) the function returns a list of allowed `domain_names`.

`assessment_units()` returns a summary of information about assessment
units.

# Examples:

``` r
library(rATTAINS)
df <- state_summary(organization_id = "TCEQMAIN", reporting_cycle = "2020")
str(df)
```

``` r
library(dplyr)
library(ggplot2)
library(ggrepel)


df %>% 
  mutate(reporting_cycle = as.numeric(reporting_cycle),
         cause_count = as.numeric(cause_count)) %>%
  group_by(reporting_cycle, use_name) %>%
  summarise(count = sum(cause_count, na.rm = TRUE)) %>%
  ungroup() %>%
  filter(!is.na(use_name)) %>%
  filter(use_name != "NONCONTACT RECREATION USE",
           use_name != "OVERALL USE SUPPORT") %>%
  mutate(use_name = case_when(
    use_name == "CONTACT RECREATION USE" ~ "Recreation Use",
    use_name == "CONTACT RECREATION" ~ "Recreation Use",
    use_name == "PRIMARY RECREATION/SWIMMING" ~ "Recreation Use",
    use_name != "PRIMARY RECREATION/SWIMMING" |
      use_name != "CONTACT RECREATION USE" |
      use_name != "CONTACT RECREATION" ~ use_name)) %>%
  filter(use_name %in% c("Recreation Use", "Fish Consumption Use", "Aquatic Life Use", "General Use"))-> plot_df

ggplot(plot_df, aes(x = reporting_cycle, y = count, group = use_name)) +
  geom_line(aes(color = use_name)) +
  geom_text_repel(data = plot_df %>% filter(reporting_cycle==2020),
                  aes(label = use_name),
                  size = 2.5,
                  hjust = "left",
                  fontface="bold",
                  direction= "y",
                  nudge_x = 5)+
  geom_text_repel(data = plot_df %>% filter(reporting_cycle==2002),
                  aes(label = use_name),
                  size = 2.5,
                  hjust = "right",
                  fontface="bold",
                  direction= "y",
                  nudge_x = -5)+
  geom_label(aes(label = count),
             size = 2,
             label.padding = unit(0.05, "lines"), 
             label.size = 0.0) +
  scale_x_continuous(position = "top",
                     breaks = c(2002,2006,2010,2014,2018),
                     expand = expansion(mult = 0.75)) +
  scale_color_brewer(palette = "Dark2") +
  theme_bw() +
  theme(axis.ticks = element_blank(),
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        axis.text.y = element_blank(),
        legend.position = "none",
        panel.border = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank()
        )
```

``` r
df <- huc12_summary(huc = "020700100204")
str(df)
```
