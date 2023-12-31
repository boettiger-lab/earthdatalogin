% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gdal-cloud-config.R
\name{gdal_cloud_unconfig}
\alias{gdal_cloud_unconfig}
\title{Restores GDAL default configuration}
\usage{
gdal_cloud_unconfig()
}
\value{
invisible TRUE if successful.
}
\description{
Unsets GDAL environmental variables set by \code{\link[=gdal_cloud_config]{gdal_cloud_config()}}
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
gdal_cloud_config()

# remove settings:
gdal_cloud_unconfig()
\dontshow{\}) # examplesIf}
}
\seealso{
\code{\link[=gdal_cloud_config]{gdal_cloud_config()}}
}
