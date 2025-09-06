# MAML

**MAML** is a **YAML** based metadata format for tabular data (roughly implying Metadata yAML). See [MAML-Format](https://github.com/asgr/MAML-Format) for details.

This package is a simple R interface to help create (based on a target table), read and write **MAML** files.

## Usage of R MAML Package

So far we have defined what **MAML** is and what it should look like, but you can actually make it however you like: by hand, your own code, or perhaps using a helper package like this one. To get going I would recommend the latter (see also [pymaml](https://github.com/TrystanScottLambert/pymaml)) because it reduces human error.

### Installation

To install the necessary dependencies, run:

```bash
install.packages("remotes")
remotes::install_github("asgr/MAML")
```

### A Simple Example 

A simple example using a toy table we want to create **MAML** metadata from:

```r
df = data.frame(
  ID = 1:5,
  Name = c("A", "B", "C", "D", "E"),
  Date = c("2025-08-26", "2025-07-22", "2025-09-03", "2025-06-13", "2025-07-26"),
  Flag = c(TRUE, FALSE, TRUE, TRUE, FALSE),
  RA = c(45.1, 47.2, 43.1, 48.9, 45.5),
  Dec = c(3.5, 2.8, 1.2, 2.9, 1.8),
  Mag = c(20.5, 20.3, 15.2, 18.8, 22.1)
)
```

This looks like:

```r
 ID Name       Date  Flag   RA Dec  Mag
  1    A 2025-08-26  TRUE 45.1 3.5 20.5
  2    B 2025-07-22 FALSE 47.2 2.8 20.3
  3    C 2025-09-03  TRUE 43.1 1.2 15.2
  4    D 2025-06-13  TRUE 48.9 2.9 18.8
  5    E 2025-07-26 FALSE 45.5 1.8 22.1
```

Now we can run **make_MAML** to automatically create much of the **MAML** schema, using information from the table itself where possible:

```r
cat(make_MAML(df))
```

Will create the following output:

```yaml
survey: Optional survey name
dataset: Recommended dataset name
table: Required table name
version: Required version (string, integer, or float)
date: '2025-09-01'
author: Required lead author name <email>
coauthors:
- Optional coauthor name <email1>
- '... <...>'
DOIs:
- DOI: Valid DOI
  type: DOI type
depends:
- survey: Dependent survey
  dataset: Dependent dataset
  table: Dependent table
  version: Dependent table version
description: Recommended short description of the table
comments:
- Optional comment or interesting fact
- '...'
license: Recommended license for the dataset / table
keywords:
- Optional keyword tag
- '...'
MAML_version: 1.0
fields:
- name: ID
  unit:
  info:
  ucd:
  data_type: int32
  array_size:
  qc:
    min: 1
    max: 5
    miss: 'Null'
- name: Name
  unit:
  info:
  ucd:
  data_type: string
  array_size:
  qc:
    min: A
    max: E
    miss: 'Null'
- name: Date
  unit:
  info:
  ucd:
  data_type: string
  array_size:
  qc:
    min: '2025-06-13'
    max: '2025-09-03'
    miss: 'Null'
- name: Flag
  unit:
  info:
  ucd:
  data_type: bool
  array_size:
  qc:
    min: 0
    max: 1
    miss: 'Null'
- name: RA
  unit:
  info:
  ucd:
  data_type: double
  array_size:
  qc:
    min: 43.1
    max: 48.9
    miss: 'Null'
- name: Dec
  unit:
  info:
  ucd:
  data_type: double
  array_size:
  qc:
    min: 1.2
    max: 3.5
    miss: 'Null'
- name: Mag
  unit:
  info:
  ucd:
  data_type: double
  array_size:
  qc:
    min: 15.2
    max: 22.1
    miss: 'Null'
```

Obviously there are more things a keen user will want to add on top of this, but it is a useful start.

We can fill out more of the fields using additional inputs to the **make_MAML** function:

```r
cat(make_MAML(df, survey='WAVES', dataset='RIP_example', table='example_data'))
```

```yaml
survey: WAVES
dataset: RIP_example
table: example_data
version: Required version (string, integer, or float)
date: '2025-09-01'
author: Required lead author name <email>
coauthors:
- Optional coauthor name <email1>
- '... <...>'
DOIs:
- DOI: Valid DOI
  type: DOI type
depends:
- survey: Dependent survey
  dataset: Dependent dataset
  table: Dependent table
  version: Dependent table version
description: Recommended short description of the table
comments:
- Optional comment or interesting fact
- '...'
license: Recommended license for the dataset / table
keywords:
- Optional keyword tag
- '...'
MAML_version: 1.0
fields:
- name: ID
  unit:
  info:
  ucd:
  data_type: int32
  array_size:
  qc:
    min: 1
    max: 5
    miss: 'Null'
- name: Name
  unit:
  info:
  ucd:
  data_type: string
  array_size:
  qc:
    min: A
    max: E
    miss: 'Null'
- name: Date
  unit:
  info:
  ucd:
  data_type: string
  array_size:
  qc:
    min: '2025-06-13'
    max: '2025-09-03'
    miss: 'Null'
- name: Flag
  unit:
  info:
  ucd:
  data_type: bool
  array_size:
  qc:
    min: 0
    max: 1
    miss: 'Null'
- name: RA
  unit:
  info:
  ucd:
  data_type: double
  array_size:
  qc:
    min: 43.1
    max: 48.9
    miss: 'Null'
- name: Dec
  unit:
  info:
  ucd:
  data_type: double
  array_size:
  qc:
    min: 1.2
    max: 3.5
    miss: 'Null'
- name: Mag
  unit:
  info:
  ucd:
  data_type: double
  array_size:
  qc:
    min: 15.2
    max: 22.1
    miss: 'Null'
```

### Lookup Autofill

To make life easier with auto-populating the **MAML** you can use a look up dictionary (itself a **YAML** file). An example looks like this:

```yaml
- pattern: ID
  match_by: suffix
  ignore_case: FALSE
  ucd: meta.id
- pattern: RA
  match_by: prefix
  ignore_case: FALSE
  ucd: pos.eq.ra
  unit: deg
- pattern: dec
  match_by: prefix
  ignore_case: TRUE
  ucd: pos.eq.dec
  unit: deg
- pattern: mag
  match_by: prefix
  ignore_case: TRUE
  ucd: phot.mag
- pattern: flux
  match_by: prefix
  ignore_case: TRUE
  ucd: phot.flux
- pattern: date
  match_by: prefix
  ignore_case: TRUE
  ucd: [time, obs.exposure]
- pattern: time
  match_by: prefix
  ignore_case: FALSE
  ucd: [time, obs.exposure]
```

Here the entries have the following meaning:

* pattern: Text string to search column names for. [required]
* match_by: Regex type. Options are 'any' (pattern); 'prefix' (^pattern); 'suffix' (pattern\$); 'exact' (^pattern\$); 'both' (^pattern|pattern\$). [optional]
* ignore_case: Should the regex matching care about the case? [optional]
* ucd: UCD to add (';' separator) based on successful column name match. [optional]
* unit: Unit to use based on successful column name match (only first match is used). [optional]
* description: Description to add (' ' separator) based on successful column name match. [optional]

To use the above example lookup **YAML** we can run:

```r
lookup = read_yaml(system.file('extdata', 'lookup.yaml', package = "MAML"))
cat(make_MAML(df, lookup=lookup))
```

This now populates our **MAML** with more information:

```yaml
survey: Optional survey name
dataset: Recommended dataset name
table: Required table name
version: Required version (string, integer, or float)
date: '2025-09-01'
author: Required lead author name <email>
coauthors:
- Optional coauthor name <email1>
- '... <...>'
DOIs:
- DOI: Valid DOI
  type: DOI type
depends:
- survey: Dependent survey
  dataset: Dependent dataset
  table: Dependent table
  version: Dependent table version
description: Recommended short description of the table
comments:
- Optional comment or interesting fact
- '...'
license: Recommended license for the dataset / table
keywords:
- Optional keyword tag
- '...'
MAML_version: 1.0
fields:
- name: ID
  unit:
  info:
  ucd:
  - meta.id
  - meta.main
  data_type: int32
  array_size:
  qc:
    min: 1
    max: 5
    miss: 'Null'
- name: Name
  unit:
  info:
  ucd:
  data_type: string
  array_size:
  qc:
    min: A
    max: E
    miss: 'Null'
- name: Date
  unit:
  info:
  ucd:
  - time
  - obs.exposure
  data_type: string
  array_size:
  qc:
    min: '2025-06-13'
    max: '2025-09-03'
    miss: 'Null'
- name: Flag
  unit:
  info:
  ucd:
  data_type: bool
  array_size:
  qc:
    min: 0
    max: 1
    miss: 'Null'
- name: RA
  unit: deg
  info:
  ucd: pos.eq.ra
  data_type: double
  array_size:
  qc:
    min: 43.1
    max: 48.9
    miss: 'Null'
- name: Dec
  unit: deg
  info:
  ucd: pos.eq.dec
  data_type: double
  array_size:
  qc:
    min: 1.2
    max: 3.5
    miss: 'Null'
- name: Mag
  unit:
  info:
  ucd: phot.mag
  data_type: double
  array_size:
  qc:
    min: 15.2
    max: 22.1
    miss: 'Null'
```

### Datamap Autofill

It is also useful to be able to standardise the column types our data might have to the range of data types supported on a particular system (say a MySQL or Postgres database). For this reason we also define an optional datatype mapping **YAML** that should look something like the below:

```yaml
- input: [short, int8, int16, i8, i16]
  output: int16
- input: [long, int, integer, int32, i32]
  output: int32
- input: [longlong, int64, i64]
  output: int64
- input: [single, float, float16, float32, f32]
  output: float32
- input: [double, numeric, float64, f64]
  output: float64
- input: [char, character, string, str, utf8, utf16, utf32, utf64]
  output: string
- input: [bit, binary, bool, boolean, logical, flag]
  output: boolean
- input: [byte, uint8, uint16, uint32, uint64, u8, u16, u32, u64, int94, uint94]
  output: error
```

Here the vector of possible inputs must always map onto a unique output. Any input and output should only appear once in this list. If an input maps to 'error' then the code will stop and return an error (since the datatype is not trivial to map to one of the desired outputs).

To use the above example datatype mapping **YAML** we can run:

```r
datamap = read_yaml(system.file('extdata', 'datamap.yaml', package = "MAML"))
cat(make_MAML(df, datamap=datamap))
```

This now populates our **MAML** with more information:

```yaml
survey: Optional survey name
dataset: Recommended dataset name
table: Required table name
version: Required version (string, integer, or float)
date: '2025-09-01'
author: Required lead author name <email>
coauthors:
- Optional coauthor name <email1>
- '... <...>'
DOIs:
- DOI: Valid DOI
  type: DOI type
depends:
- survey: Dependent survey
  dataset: Dependent dataset
  table: Dependent table
  version: Dependent table version
description: Recommended short description of the table
comments:
- Optional comment or interesting fact
- '...'
license: Recommended license for the dataset / table
keywords:
- Optional keyword tag
- '...'
MAML_version: 1.0
fields:
- name: ID
  unit:
  info:
  ucd:
  data_type: int32
  array_size:
  qc:
    min: 1
    max: 5
    miss: 'Null'
- name: Name
  unit:
  info:
  ucd:
  data_type: string
  array_size:
  qc:
    min: A
    max: E
    miss: 'Null'
- name: Date
  unit:
  info:
  ucd:
  data_type: string
  array_size:
  qc:
    min: '2025-06-13'
    max: '2025-09-03'
    miss: 'Null'
- name: Flag
  unit:
  info:
  ucd:
  data_type: boolean
  array_size:
  qc:
    min: 0
    max: 1
    miss: 'Null'
- name: RA
  unit:
  info:
  ucd:
  data_type: float64
  array_size:
  qc:
    min: 43.1
    max: 48.9
    miss: 'Null'
- name: Dec
  unit:
  info:
  ucd:
  data_type: float64
  array_size:
  qc:
    min: 1.2
    max: 3.5
    miss: 'Null'
- name: Mag
  unit:
  info:
  ucd:
  data_type: float64
  array_size:
  qc:
    min: 15.2
    max: 22.1
    miss: 'Null'
```

Notice how the data_type entries have been updated to reflect the desired mapping. Naturally you can combine the *lookup* and *data_type* options, and hopefully the typical user is more than half way to filling out a useful MAML.

## Conclusions

The hope is these tools get the typical user 80% of the way to making a useful **MAML** file, but suggestions on how to better automate this process are always welcome (use GitHub Issues).
