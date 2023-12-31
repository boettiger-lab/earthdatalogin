% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/edl_set_token.R
\name{edl_revoke_token}
\alias{edl_revoke_token}
\title{Revoke an EarthData token}
\usage{
edl_revoke_token(
  username = default("user"),
  password = default("password"),
  token_number = 1
)
}
\arguments{
\item{username}{EarthData Login User}

\item{password}{EarthData Login Password}

\item{token_number}{Which token (1 or 2)}
}
\value{
API response (invisibly)
}
\description{
Users can only have at most 2 active tokens at any time.
You don't need to keep track of a token since earthdatalogin can
retrieve your tokens with your user name and password.  However,
should you want to revoke a token, you can do so with this function.
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
edl_revoke_token()
\dontshow{\}) # examplesIf}
}
