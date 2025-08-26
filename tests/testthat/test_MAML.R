library(testthat)

context("Check Rfits table/image read/write")
# Read the MAML file
current = read_MAML(system.file('extdata', 'example.maml', package = "MAML"), output='yaml')

# Create the MAML output from target parquet
ds = open_dataset(system.file('extdata', 'example.parquet', package = "MAML"))
new = make_MAML(ds)

# Check if the result is equal to temp
expect_equal(current, new)
