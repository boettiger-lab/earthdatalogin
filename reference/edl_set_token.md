# Get or set an earthdata login token

This function will ping the EarthData API for any available tokens. If a
token is not found, it will request one. You may only have two active
tokens at any given time. Use edl_revoke_token to remove unwanted
tokens. By default, the function will also set an environmental variable
for the active R session to store the token. This allows popular R
packages which use gdal to immediately authenticate any http addresses
to NASA EarthData assets.

## Usage

``` r
edl_set_token(
  username = default("user"),
  password = default("password"),
  token_number = 1,
  set_env_var = TRUE,
  format = c("token", "header", "file"),
  prompt_for_netrc = interactive()
)
```

## Arguments

- username:

  EarthData Login User

- password:

  EarthData Login Password

- token_number:

  Which token (1 or 2)

- set_env_var:

  Should we set the GDAL_HTTP_HEADER_FILE environmental variable?
  logical, default TRUE.

- format:

  One of "token", "header" or "file." "header" adds the prefix used by
  http headers to the return string. "file" returns

- prompt_for_netrc:

  Often netrc is preferable, so this function will by default prompt the
  user to switch. Set to FALSE to silence this.

## Value

A text string containing only the token (format=token), or a token with
the header prefix included, `Authorization: Bearer <token>`

## Details

IMPORTANT: it is necessary to unset this token using
[`edl_unset_token()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_unset_token.md)
before trying to access HTTP resources that are not part of EarthData,
as setting this token will cause those calls to fail! OR simply use
[`edl_netrc()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_netrc.md)
to authenticate without facing this issue.

NOTE: Because GDAL \>= 3.6.1 is required to recognize the
GDAL_HTTP_HEADERS, but all versions recognize GDAL_HTTP_HEADER_FILE. So
we set the Bearer token in a temporary file and provide this path as
GDAL_HTTP_HEADER_FILE to improve compatibility with older versions.

## Examples

``` r
if (FALSE) { # interactive()
edl_set_token()
edl_unset_token()
}
```
