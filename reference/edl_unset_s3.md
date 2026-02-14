# Unset AWS S3 Environment Variables

The function uses
[`Sys.unsetenv()`](https://rdrr.io/r/base/Sys.setenv.html) to remove the
specified environment variables.

## Usage

``` r
edl_unset_s3()
```

## Details

This function unsets the AWS S3-related environment variables:
`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_SESSION_TOKEN`.

## See also

[`Sys.unsetenv`](https://rdrr.io/r/base/Sys.setenv.html)

## Examples

``` r
if (FALSE) { # interactive()
edl_unset_s3()
}
```
