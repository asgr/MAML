# AGENTS.md

R package **MAML** (Metadata with YAML): create, read, write, merge and validate table metadata in the MAML (YAML) format.

## Layout
- `R/make_MAML.R` – `make_MAML()` builds metadata from a data frame/arrow table (supports `lookup`, `datamap`, `vec_col` for MAML 1.2).
- `R/read_MAML.R` – `read_MAML()`, `MAML_to_list()`, `list_to_MAML()`.
- `R/write_MAML.R` – `write_MAML()` to `.maml` text or embedded in parquet metadata.
- `R/merge_MAML.R` – `merge_MAML()` (`prefer='primary'|'secondary'`).
- `R/validate_MAML.R` – `validate_MAML()` (JSON schema via jsonvalidate/ajv + UCD checks), `ucd_validate()`.
- `R/fields_flat_MAML.R` – `fields_flat_MAML()`.
- `inst/extdata/` – JSON schemas (`MAML_schema_v1p0/1p1/1p2.json`), UCD list, and example `.maml`/`.parquet`/`.yaml` fixtures.
- `tests/testthat/` – testthat tests (`test_MAML.R` golden-file tests, `test_utils.R` unit tests).

## Conventions
- Exports use `exportPattern("^[[:alpha:]]+")` in `NAMESPACE`: any function whose name starts with a letter is exported; prefix internal helpers with `.`.
- Dependencies are in `Depends`; the package uses `=` for assignment and `foreach` for loops.
- Always reference fixtures via `system.file('extdata', ..., package = "MAML")`.
- Changing `make_MAML` output means regenerating the `example_*.maml` fixtures in `inst/extdata/`.

## Workflow
- Install deps, then: `R CMD INSTALL .` and `Rscript -e 'testthat::test_local()'` (or `devtools::test()`).
- Full check: `R CMD build . && R CMD check MAML_*.tar.gz`.
- CI: `.github/workflows/R-CMD-check.yaml` runs R CMD check (incl. tests) on Linux/macOS/Windows.
- Update `man/*.Rd` when changing function signatures.
