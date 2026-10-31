library(testthat)
library(yaml)

ex = function(f) system.file('extdata', f, package = "MAML")

test_that("read_MAML returns list or MAML and rejects bad output", {
  l = read_MAML(ex('example_default.maml'))
  expect_type(l, 'list')
  expect_true('fields' %in% names(l))
  m = read_MAML(ex('example_default.maml'), output = 'MAML')
  expect_s3_class(m, 'MAML')
  expect_error(read_MAML(ex('example_default.maml'), output = 'bad'))
})

test_that("MAML_to_list / list_to_MAML round trip", {
  l = read_MAML(ex('example_default.maml'))
  m = list_to_MAML(l)
  expect_s3_class(m, 'MAML')
  expect_equal(MAML_to_list(m), l)
  expect_warning(MAML_to_list(unclass(m)), 'class MAML')
  expect_error(suppressWarnings(MAML_to_list(1:3)))
})

test_that("write_MAML writes to maml and parquet", {
  m = read_MAML(ex('example_default.maml'), output = 'MAML')
  f = tempfile(fileext = '.maml')
  write_MAML(m, f)
  expect_equal(read_MAML(f), read_MAML(ex('example_default.maml')))

  f2 = tempfile(fileext = '.maml')
  write_MAML(read_MAML(ex('example_default.maml')), f2, input = 'list')
  expect_true(file.exists(f2))

  df = data.frame(a = 1:3, b = c('x', 'y', 'z'))
  fp = tempfile(fileext = '.parquet')
  write_MAML(m, fp, table = df, output = 'parquet')
  back = read_parquet(fp, as_data_frame = FALSE)
  expect_true(!is.null(back$metadata$maml))

  expect_error(write_MAML(1, f))
  expect_error(write_MAML(m, f, output = 'bad'))
})

test_that("make_MAML output types and errors", {
  df = data.frame(a = 1:3, b = c('x', 'y', 'z'), c = c(1.5, 2.5, 3.5))
  expect_s3_class(make_MAML(df), 'MAML')
  expect_type(make_MAML(df, output = 'list'), 'list')
  expect_error(make_MAML(df, output = 'bad'))
  expect_error(make_MAML(df, input = 'bad'))
  l = make_MAML(df, output = 'list')
  expect_equal(length(l$fields), 3L)
})

test_that("make_MAML vec_col requires adjacent columns", {
  df = data.frame(t_1 = 1:3, x = 1:3, t_2 = 1:3)
  expect_error(make_MAML(df, MAML_version = 1.2, vec_col = 't'), 'adjacent')
})

test_that("fields_flat_MAML flattens fields", {
  flat = fields_flat_MAML(read_MAML(ex('example_lookup.maml'), output = 'MAML'))
  expect_s3_class(flat, 'data.frame')
  expect_true('name' %in% names(flat))
  flat2 = fields_flat_MAML(read_MAML(ex('example_lookup.maml'), output = 'MAML'),
                           fields_keep = 'name')
  expect_equal(names(flat2), 'name')
})

test_that("merge_MAML prefers primary or secondary", {
  p = list(survey = 'A', dataset = NULL, fields = list(list(name = 'a', unit = 'm', info = NULL)))
  s = list(survey = 'B', dataset = 'D', fields = list(list(name = 'a', unit = 'km', info = 'hi')))
  r = merge_MAML(p, s, output = 'list')
  expect_equal(r$survey, 'A')
  expect_equal(r$dataset, 'D')
  expect_equal(r$fields[[1]]$unit, 'm')
  expect_equal(r$fields[[1]]$info, 'hi')
  r2 = merge_MAML(p, s, prefer = 'secondary', output = 'list')
  expect_equal(r2$survey, 'B')
  expect_equal(r2$fields[[1]]$unit, 'km')
  expect_s3_class(merge_MAML(p, s), 'MAML')
  expect_error(merge_MAML(p, s, output = 'bad'))
})

test_that("ucd_validate checks primary/secondary positions", {
  expect_true(ucd_validate('arith'))
  expect_false(ucd_validate('not.a.real.ucd'))
  expect_true(ucd_validate('arith;arith.diff'))
})

test_that("validate_MAML fails on schema-violating input", {
  m = read_MAML(ex('example_default.maml'))
  m$fields = 'nonsense'
  expect_false(suppressMessages(validate_MAML(m)))
  expect_true(suppressMessages(validate_MAML(read_MAML(ex('example_default.maml')))))
})
