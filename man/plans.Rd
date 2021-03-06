% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plans.R
\name{plans}
\alias{plans}
\title{Download Plans and Actions by HUC}
\usage{
plans(huc = NULL, organization_id = NULL, summarize = FALSE, ...)
}
\arguments{
\item{huc}{(character) 8-digit or higher HUC. required}

\item{organization_id}{(character). optional}

\item{summarize}{(logical)}

\item{...}{list of curl options passed to \code{\link[crul:HttpClient]{crul::HttpClient()}}}
}
\value{
tibble
}
\description{
Download Plans and Actions by HUC
}
