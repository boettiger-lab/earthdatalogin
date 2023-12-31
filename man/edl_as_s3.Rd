% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/edl_s3_token.R
\name{edl_as_s3}
\alias{edl_as_s3}
\title{Replace https URLs with S3 URIs}
\usage{
edl_as_s3(href, prefix = "s3://")
}
\arguments{
\item{href}{a https URL from an EarthData Cloud address}

\item{prefix}{the preferred s3 prefix, e.g. \verb{s3://} (understood by gdalcubes),
or \verb{/vsis3}, for terra/stars/sf or other GDAL-based interfaces.}
}
\value{
a URI that strips basename and protocol and appends prefix
}
\description{
Replace https URLs with S3 URIs
}
\examples{
href <- lpdacc_example_url()
edl_as_s3(href)
}
