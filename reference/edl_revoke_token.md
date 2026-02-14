# Revoke an EarthData token

Users can only have at most 2 active tokens at any time. You don't need
to keep track of a token since earthdatalogin can retrieve your tokens
with your user name and password. However, should you want to revoke a
token, you can do so with this function.

## Usage

``` r
edl_revoke_token(
  username = default("user"),
  password = default("password"),
  token_number = 1
)
```

## Arguments

- username:

  EarthData Login User

- password:

  EarthData Login Password

- token_number:

  Which token (1 or 2)

## Value

API response (invisibly)

## Examples

``` r
if (FALSE) { # interactive()
edl_revoke_token()
}
```
