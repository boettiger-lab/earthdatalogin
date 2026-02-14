# NASA Earthdata S3 Credentials Authentication

Authenticates with NASA Earthdata to obtain temporary S3 credentials for
accessing NASA Earth observation data stored in S3 buckets. The function
performs an OAuth-like authentication flow and automatically sets the
required AWS environment variables.

## Usage

``` r
edl_s3_token(
  daac = "https://data.lpdaac.earthdatacloud.nasa.gov",
  username = default("user"),
  password = default("password"),
  prompt_for_netrc = interactive()
)
```

## Arguments

- daac:

  Character string. The base URL for the DAAC (Data Archive Access
  Center). Defaults to "https://data.lpdaac.earthdatacloud.nasa.gov".

- username:

  Character string. EarthDataLogin username. Defaults to the value
  returned by `default("user")`.

- password:

  Character string. EarthDataLogin password. Defaults to the value
  returned by `default("password")`.

- prompt_for_netrc:

  Logical. Often netrc is preferable, so this function will by default
  prompt the user to switch. Set to FALSE to silence this. Defaults to
  [`interactive()`](https://rdrr.io/r/base/interactive.html).

## Value

Invisibly returns a list containing the S3 credentials:

- accessKeyId:

  AWS access key ID

- secretAccessKey:

  AWS secret access key

- sessionToken:

  AWS session token

- expiration:

  Token expiration time

## Details

Note that these S3 credentials will only work:

- On AWS instance in the `us-west-2` region

- Only for one hour before they expire

- Only on the DAAC requested

Please consider using
[`edl_netrc()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_netrc.md)
to avoid these limitations

This function performs a multi-step authentication process:

1.  Requests authorization URL from the credentials endpoint

2.  Posts credentials to get a redirect URL

3.  Follows redirect to set authentication cookies

4.  Makes final request with cookies to obtain S3 credentials

The function automatically sets the following environment variables:

- `AWS_ACCESS_KEY_ID`

- `AWS_SECRET_ACCESS_KEY`

- `AWS_SESSION_TOKEN`

## Examples

``` r
if (FALSE) { # interactive()
edl_s3_token()
}
```
