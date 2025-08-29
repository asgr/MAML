# MAML

MAML is a YAML based metadata format for tabular data. This package is a simple R interface to help create, read and write MAML files.

Why MAML? We have VOTable and FITS header already?! Well, for various projects we were keen on a rich metadata format that was easy for humans and computers to both read and write. VOTable headers are very hard for humans to read and write (boo), and FITS is very restrictive with its formatting and only useful for FITS files directly. In comes YAML, a very human and machine readable and writable format. By restricting ourselves to a narrow subset of the language we can easily describe fairly complex table metadata (including all IVOA information). So this brings us to MAML: Metadata yAML (it kinda works :-P).

MAML format files should be saves as example.maml etc. And the idea is the yaml string can be inserted directly into a number of different file formats that accept key-value metadata (like Apache Arrow Parquet files). In the case of Parquet files they should be written to a 'maml' extension in the metadata section of the file (so something like parquet_file\$metadata\$maml in R world).

## MAML Metadata Format

The MAML metadata format is a structured way to describe datasets, surveys, and tables using YAML. This format ensures that all necessary information about the data is captured in a clear and organized manner.

### Structure

The superset of allowed entries for MAML is below. Not all are required, but if present they should obey the order and naming.

* survey: The name of the survey. Scalar string. [recommended]
* dataset: The name of the dataset. Scalar string. [recommended]
* table: The name of the table. Scalar string. [required]
* version: The version of the dataset. Scalar string, integer or float. [required]
* date: The date of the dataset in YYYY-MM-DD format. Scalar string. [required]
* author: The lead author of the dataset, including their email. Scalar string. [required]
* coauthors: A list of co-authors, each with their email. Vector string. [optional]
* depend: A list of datasets that this dataset depends on. Vector string. [optional]
* comment: A list of comments or interesting facts about the data. Vector string. [optional]
* fields: A list of fields in the dataset, each with the following attributes: [required]
  - name: The name of the field. Scalar string. [required]
  - unit: The unit of measurement for the field (if applicable). Scalar string. [recommended]
  - description: A description of the field. Scalar string. [recommended]
  - ucd: Unified Content Descriptor for IVOA. Scalar string. [recommended]
  - data_type: The data type of the field (e.g., int32, string, bool, double). Scalar string. [required]

This metadata format can be used to document datasets in a standardised way, making it easier to understand and share data within the research community. By following this format, you ensure that all relevant information about the dataset is captured and easily accessible.

This format contains the superset of metadata requirements for IVOA, Data Central and surveys like GAMA and WAVES.

## Usage of R MAML Package

So far we have defined what MAML is and what it should look like, but you can actually make it however you like: by hand, your own code, or perhaps using a helper package like this one. To get going I would recommend the latter (see also *pymaml*) because it reduces human error.

### Installation

To install the necessary dependencies, run:

```bash
install.packages("remotes")
remotes::install_github("asgr/MAML")
```

### A Simple Example 

A simple example using a toy table we want to create MAML metadata from:

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

Now running make_MAML:

```r
cat(make_MAML(df))
```

Will create the following output:

```yaml
survey: Survey Name
dataset: Dataset Name
table: Table Name
version: '0.0'
date: '2025-08-26'
author: Lead Author <email>
coauthors:
- Co-Author 1 <email1>
- Co-Author 2 <email2>
depend:
- Dataset 1 this depends on [optional]
- Dataset 2 this depends on [optional]
comment:
- Something interesting about the data [optional]
- Something else [optional]
fields:
- name: ID
  unit: 
  description: 
  ucd: 
  data_type: int32
- name: Name
  unit: 
  description: 
  ucd: 
  data_type: string
- name: Date
  unit: 
  description: 
  ucd: 
  data_type: string
- name: Flag
  unit: 
  description: 
  ucd: 
  data_type: bool
- name: RA
  unit: 
  description: 
  ucd: 
  data_type: double
- name: Dec
  unit: 
  description: 
  ucd: 
  data_type: double
- name: Mag
  unit: 
  description: 
  ucd: 
  data_type: double
```

Obviously there are more things a keen user will want to add on top of this, but it is a useful start.

### Lookup Autofill

To make life easier with auto-populating the MAML you can use a look up dictionary (itself a YAML file). An example looks like this:

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

To use the above example lookup YAML we can run:

```r
lookup = read_yaml(system.file('extdata', 'lookup.yaml', package = "MAML"))
cat(make_MAML(df, lookup=lookup))
```

This now populates our MAML with more information:

```yaml
survey: Survey Name
dataset: Dataset Name
table: Table Name
version: '0.0'
date: '2025-08-26'
author: Lead Author <email>
coauthors:
- Co-Author 1 <email1>
- Co-Author 2 <email2>
depend:
- Dataset 1 this depends on [optional]
- Dataset 2 this depends on [optional]
comment:
- Something interesting about the data [optional]
- Something else [optional]
fields:
- name: ID
  unit: 
  description: 
  ucd: meta.id
  data_type: int32
- name: Name
  unit: 
  description: 
  ucd: 
  data_type: string
- name: Date
  unit: 
  description: 
  ucd: time;obs.exposure
  data_type: string
- name: Flag
  unit: 
  description: 
  ucd: 
  data_type: bool
- name: RA
  unit: deg
  description: 
  ucd: pos.eq.ra
  data_type: double
- name: Dec
  unit: deg
  description: 
  ucd: pos.eq.dec
  data_type: double
- name: Mag
  unit: 
  description: 
  ucd: phot.mag
  data_type: double
```

### Datamap Autofill

It is also useful to be able to standardise the column types our data might have to the range of data types supported on a particular system (say a MySQL or Postgres database). For this reason we also define an optional datatype mapping YAML that should look something like the below:

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

To use the above example datatype mapping YAML we can run:

```r
datamap = read_yaml(system.file('extdata', 'datamap.yaml', package = "MAML"))
cat(make_MAML(df, datamap=datamap))
```

This now populates our MAML with more information:

```yaml
survey: Survey Name
dataset: Dataset Name
table: Table Name
version: '0.0'
date: '2025-08-28'
author: Lead Author <email>
coauthors:
- Co-Author 1 <email1>
- Co-Author 2 <email2>
depend:
- Dataset 1 this depends on [optional]
- Dataset 2 this depends on [optional]
comment:
- Something interesting about the data [optional]
- Something else [optional]
fields:
- name: ID
  unit: 
  description: 
  ucd: 
  data_type: int32
- name: Name
  unit: 
  description: 
  ucd: 
  data_type: string
- name: Date
  unit: 
  description: 
  ucd: 
  data_type: string
- name: Flag
  unit: 
  description: 
  ucd: 
  data_type: boolean
- name: RA
  unit: 
  description: 
  ucd: 
  data_type: float64
- name: Dec
  unit: 
  description: 
  ucd: 
  data_type: float64
- name: Mag
  unit: 
  description: 
  ucd: 
  data_type: float64
```

Notice how the data_type entries have been updated to reflect the desired mapping.
