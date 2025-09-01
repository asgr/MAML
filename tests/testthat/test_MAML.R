library(testthat)

context("Check Rfits table/image read/write")
# Read the MAML file
example_default = read_MAML(system.file('extdata', 'example_default.maml', package = "MAML"), output='yaml')
example_lookup = read_MAML(system.file('extdata', 'example_lookup.maml', package = "MAML"), output='yaml')
example_datamap = read_MAML(system.file('extdata', 'example_datamap.maml', package = "MAML"), output='yaml')
example_lookup_datamap = read_MAML(system.file('extdata', 'example_lookup_datamap.maml', package = "MAML"), output='yaml')
example_fields_lookup_datamap = read_MAML(system.file('extdata', 'example_fields_lookup_datamap.maml', package = "MAML"), output='yaml')

lookup = read_yaml(system.file('extdata', 'lookup.yaml', package = "MAML"))
datamap = read_yaml(system.file('extdata', 'datamap.yaml', package = "MAML"))

# Create the MAML output from target parquet
ds = read_parquet(system.file('extdata', 'example.parquet', package = "MAML"))

new_default = make_MAML(ds)
new_lookup = make_MAML(ds, lookup=lookup)
new_datamap = make_MAML(ds, datamap=datamap)
new_lookup_datamap = make_MAML(ds, lookup=lookup, datamap=datamap)
new_fields_lookup_datamap = make_MAML(ds, fields_optional = c('unit', 'ucd'),
                                      lookup=lookup, datamap=datamap)

# Check if the result is equal to temp
expect_equal(example_default, new_default)
expect_equal(example_lookup, new_lookup)
expect_equal(example_datamap, new_datamap)
expect_equal(example_lookup_datamap, new_lookup_datamap)
expect_equal(example_fields_lookup_datamap, new_fields_lookup_datamap)
