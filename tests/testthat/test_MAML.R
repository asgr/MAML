library(testthat)
library(yaml)

context("Check Rfits table/image read/write")
# Read the MAML file
example_default = read_MAML(system.file('extdata', 'example_default.maml', package = "MAML"), output='MAML')
example_lookup = read_MAML(system.file('extdata', 'example_lookup.maml', package = "MAML"), output='MAML')
example_datamap = read_MAML(system.file('extdata', 'example_datamap.maml', package = "MAML"), output='MAML')
example_lookup_datamap = read_MAML(system.file('extdata', 'example_lookup_datamap.maml', package = "MAML"), output='MAML')
example_fields_lookup_datamap = read_MAML(system.file('extdata', 'example_fields_lookup_datamap.maml', package = "MAML"), output='MAML')

lookup = read_yaml(system.file('extdata', 'lookup.yaml', package = "MAML"))
datamap = read_yaml(system.file('extdata', 'datamap.yaml', package = "MAML"))

# Create the MAML output from target parquet
df = read_parquet(system.file('extdata', 'example.parquet', package = "MAML"))

new_default = make_MAML(df, date='2025-09-01')
new_lookup = make_MAML(df, lookup=lookup, date='2025-09-01')
new_datamap = make_MAML(df, datamap=datamap, date='2025-09-01')
new_lookup_datamap = make_MAML(df, lookup=lookup, datamap=datamap, date='2025-09-01')
new_fields_lookup_datamap = make_MAML(df, fields_optional = c('unit', 'ucd'),
                                      lookup=lookup, datamap=datamap, date='2025-09-01')

# Check if the MAMLs pass the current validator
expect_true(validate_MAML(new_default))
expect_true(validate_MAML(new_lookup))
expect_true(validate_MAML(new_datamap))
expect_true(validate_MAML(new_lookup_datamap))
expect_true(validate_MAML(new_fields_lookup_datamap))

# UCD checks:
expect_true(ucd_validate("arith"))
expect_false(ucd_validate("arith.diff"))
expect_true(ucd_validate(c("arith", "arith.diff")))

# Check if the newly generated MAML result is equal to the expected
expect_equal(example_default, new_default)
expect_equal(example_lookup, new_lookup)
expect_equal(example_datamap, new_datamap)
expect_equal(example_lookup_datamap, new_lookup_datamap)
expect_equal(example_fields_lookup_datamap, new_fields_lookup_datamap)

# Create the MAML output from target vector column parquet
df_veccol = read_parquet(system.file('extdata', 'example_veccol_maml.parquet', package = "MAML"))

# Check we see a vector column (should be class AsIs)
expect_true(inherits(df_veccol$spec, 'AsIs'))

maml_veccol1 = make_MAML(df_veccol, MAML_version=1.2)

# Check if the MAML passes the current validator
expect_true(validate_MAML(maml_veccol1, MAML_version = 1.2))

#Check it fails the others:
expect_false(validate_MAML(maml_veccol1, MAML_version = 1.0))
expect_false(validate_MAML(maml_veccol1, MAML_version = 1.1))

test_vec_dt1 = data.frame(
  ID=1:10,
  test = I(lapply(rep(2,10),runif)),
  filler = 11:20,
  other = I(lapply(rep(3,10),runif)),
  end = 21:30
)

maml_veccol2 = make_MAML(test_vec_dt1, MAML_version=1.2)

# Check if the MAML passes the current validator
expect_true(validate_MAML(maml_veccol2, MAML_version = 1.2))

test_vec_dt2 = data.frame(
  ID = 1:10,
  test_1 = runif(10), test_2 = runif(10),
  filler = 11:20,
  other_1 = runif(10), other_2 = runif(10), other_3 = runif(10),
  end = 21:30
)

maml_veccol3 = make_MAML(test_vec_dt2, MAML_version=1.2, vec_col=c('test', 'other'))

# Check if the MAML passes the current validator
expect_true(validate_MAML(maml_veccol3, MAML_version = 1.2))
