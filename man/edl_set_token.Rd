% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/edl_set_token.R
\name{edl_set_token}
\alias{edl_set_token}
\title{Get or set an earthdata login token}
\usage{
edl_set_token(
  username = default("user"),
  password = default("password"),
  token_number = 1,
  set_env_var = TRUE,
  format = c("token", "header", "file"),
  prompt_for_netrc = interactive()
)
}
\arguments{
\item{username}{EarthData Login User}

\item{password}{EarthData Login Password}

\item{token_number}{Which token (1 or 2)}

\item{set_env_var}{Should we set the GDAL_HTTP_HEADER_FILE
environmental variable?  logical, default TRUE.}

\item{format}{One of "token", "header" or "file."  "header" adds the prefix
used by http headers to the return string.  "file" returns}

\item{prompt_for_netrc}{Often netrc is preferable, so this function will by
default prompt the user to switch.  Set to FALSE to silence this.}
}
\value{
A text string containing only the token (format=token),
or a token with the header prefix included, \verb{Authorization: Bearer <token>}
}
\description{
This function will ping the EarthData API for any available tokens.
If a token is not found, it will request one.  You may only have
two active tokens at any given time.  Use edl_revoke_token to remove
unwanted tokens.  By default, the function will also set an environmental
variable for the active R session to store the token.  This allows
popular R packages which use gdal to immediately authenticate any http
addresses to NASA EarthData assets.
}
\details{
IMPORTANT: it is necessary to unset this token using \code{\link[=edl_unset_token]{edl_unset_token()}}
before trying to access HTTP resources that are not part of EarthData,
as setting this token will cause those calls to fail! OR simply use
\code{\link[=edl_netrc]{edl_netrc()}} to authenticate without facing this issue.

NOTE: Because GDAL >= 3.6.1 is required to recognize the GDAL_HTTP_HEADERS,
but all versions recognize GDAL_HTTP_HEADER_FILE. So we set the Bearer token
in a temporary file and provide this path as GDAL_HTTP_HEADER_FILE to
improve compatibility with older versions.
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
edl_set_token()
edl_unset_token()
\dontshow{\}) # examplesIf}
}
