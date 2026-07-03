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

# -----------------------------------------------------------------------
# VOTable_to_MAML / MAML_to_VOTable round-trip tests
# -----------------------------------------------------------------------

# Build a minimal VOTable meta_col data frame (scalar columns only)
votable_meta = data.frame(
  Name        = c("ID", "RA", "Dec", "Mag", "SpType"),
  Unit        = c(NA,   "deg", "deg", "mag", NA),
  Description = c("Row ID", "Right Ascension", "Declination", "Magnitude", "Spectral type"),
  UCD         = c(NA, "pos.eq.ra", "pos.eq.dec", "phot.mag", NA),
  Datatype    = c("int", "double", "double", "float", "char"),
  Arraysize   = c(NA, NA, NA, NA, "10"),
  stringsAsFactors = FALSE
)

# --- MAML v1.0 round-trip ---
maml10_list = VOTable_to_MAML(votable_meta, MAML_version = 1.0)
expect_equal(length(maml10_list$fields), nrow(votable_meta))
expect_equal(maml10_list$MAML_version, 1.0)

rt10 = MAML_to_VOTable(maml10_list)
expect_equal(rt10$Name,     votable_meta$Name)
expect_equal(rt10$Datatype, votable_meta$Datatype)
expect_equal(rt10$Unit,     votable_meta$Unit)
expect_equal(rt10$UCD,      votable_meta$UCD)
# array_size for the char column should round-trip as "10"
expect_equal(rt10$Arraysize[rt10$Name == "SpType"], "10")

# --- MAML v1.1 round-trip (same field structure as v1.0) ---
maml11_list = VOTable_to_MAML(votable_meta, MAML_version = 1.1)
expect_equal(maml11_list$MAML_version, 1.1)

rt11 = MAML_to_VOTable(maml11_list)
expect_equal(rt11$Name,     votable_meta$Name)
expect_equal(rt11$Datatype, votable_meta$Datatype)

# --- MAML v1.2 round-trip with a vector column ---
votable_vec = data.frame(
  Name        = c("ID", "flux", "label"),
  Unit        = c(NA,   "Jy",   NA),
  Description = c("Identifier", "Flux vector", "Source label"),
  UCD         = c(NA, "phot.flux", NA),
  Datatype    = c("int", "float", "char"),
  Arraysize   = c(NA, "5", "20"),
  stringsAsFactors = FALSE
)

maml12_list = VOTable_to_MAML(votable_vec, MAML_version = 1.2)
# numeric arraysize on non-string column → col_size
expect_equal(maml12_list$fields[[2]]$col_size, 5L)
# char arraysize → array_size, not col_size
expect_null(maml12_list$fields[[3]]$col_size)
expect_equal(maml12_list$fields[[3]]$array_size, 20L)

rt12 = MAML_to_VOTable(maml12_list)
expect_equal(rt12$Name,     votable_vec$Name)
expect_equal(rt12$Datatype, votable_vec$Datatype)
# col_size=5 should come back as Arraysize="5"
expect_equal(rt12$Arraysize[rt12$Name == "flux"],  "5")
expect_equal(rt12$Arraysize[rt12$Name == "label"], "20")

# --- MAML list → VOTable → MAML list round-trip ---
maml_from_example = read_MAML(
  system.file('extdata', 'example_lookup_datamap.maml', package = "MAML"),
  output = 'list'
)
vot_from_maml = MAML_to_VOTable(maml_from_example)
expect_equal(nrow(vot_from_maml), length(maml_from_example$fields))
# Field names are preserved
expect_equal(vot_from_maml$Name,
             vapply(maml_from_example$fields, `[[`, character(1), 'name'))

# --- UCD semicolon-collapse in MAML_to_VOTable ---
maml_multi_ucd = maml_from_example
# Inject a two-element UCD vector into the first field
maml_multi_ucd$fields[[1]]$ucd = c("meta.id", "meta.main")
vot_multi = MAML_to_VOTable(maml_multi_ucd)
expect_equal(vot_multi$UCD[1], "meta.id;meta.main")
