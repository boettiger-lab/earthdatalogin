% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gdal-cloud-config.R
\name{gdal_cloud_config}
\alias{gdal_cloud_config}
\title{Recommended GDAL configuration for cloud-based access}
\usage{
gdal_cloud_config()
}
\value{
sets recommended environmental variables and returns invisible TRUE
if successful.
}
\description{
Sets GDAL environmental variables to recommended optimum settings for
cloud-based access.
}
\details{
Based on
\url{https://gdalcubes.github.io/source/concepts/config.html#recommended-settings-for-cloud-access}
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
gdal_cloud_config()

# remove settings:
gdal_cloud_unconfig()
\dontshow{\}) # examplesIf}
}
\seealso{
\code{\link[=gdal_cloud_unconfig]{gdal_cloud_unconfig()}}
}
