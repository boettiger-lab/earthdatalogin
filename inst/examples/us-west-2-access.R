library(earthdatalogin)

# Set auth tokens -- assumes LPDAAC, specify your DAAC!
edl_s3_token()

# A random example COG from LPDAAC
url <- lpdacc_example_url()

# Reformat as an S3 URI
s3_addr <- edl_as_s3(url)

# peak at it
s3_addr

# here we go
terra::rast(s3_addr)
