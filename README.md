# MAML

MAML is a YAML based metadata format for tabular data. This package is a simple R interface to help create, read and write MAML files.

Why MAML? We have VOTable and FITS header already?! Well, for various projects we were keen on a rich metadata format that was easy for humans and computers to both read and write. VOTable headers are very hard for humans to read and write (boo), and FITS is very restrictive with its formatting and only useful for FITS files directly. In comes YAML, a very human and machine readable and writable format. By restricting ourselves to a narrow subset of the language we can easily describe fairly complex table metadata (including all IVOA information). So this brings us to MAML: Metadata yAML (it kinda works :-P).

MAML format files should be saves as example.maml etc. And the idea is the yaml string can be inserted directly into a number of different file formats that accept key-value metadata (like Apache Arrow Parquet files). In the case of Parquet files they should be written to a 'maml' extension in the metadata section of the file (so something like parquet_file\$metadata\$maml in R world).

### Installation

To install the necessary dependencies, run:

```bash
install.packages("remotes")
remotes::install_github("asgr/MAML")
```

### Usage

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
dataset: dataset Name
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

## MAML Metadata Format

The MAML metadata format is a structured way to describe datasets, surveys, and tables using YAML. This format ensures that all necessary information about the data is captured in a clear and organized manner.

### Structure

* survey: The name of the survey. [recommended]
* dataset: The name of the dataset. [recommended]
* table: The name of the table. [required]
* version: The version of the dataset. [required]
* date: The date of the dataset in YYYY-MM-DD format. [required]
* author: The lead author of the dataset, including their email. [required]
* coauthors: A list of co-authors, each with their email. [optional]
* depend: A list of datasets that this dataset depends on. [optional]
* comment: A list of comments or interesting facts about the data. [optional]
* fields: A list of fields in the dataset, each with the following attributes: [required]
  - name: The name of the field. [required]
  - unit: The unit of measurement for the field (if applicable). [recommended]
  - description: A description of the field. [recommended]
  - ucd: Unified Content Descriptor for IVOA. [recommended]
  - data_type: The data type of the field (e.g., int32, string, bool, double). [required]

This metadata format can be used to document datasets in a standardised way, making it easier to understand and share data within the research community. By following this format, you ensure that all relevant information about the dataset is captured and easily accessible.

This format contains the superset of metadata requirements for IVOA, Data Central and surveys like GAMA and WAVES.

## Lookup Autofill

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

To use the above lookup YAML we can run:

```r
lookup = read_yaml(system.file('extdata', 'lookup.yaml', package = "MAML"))
cat(make_MAML(df, lookup=lookup))
```

This now populates our MAML with more information:

```yaml
survey: Survey Name
dataset: dataset Name
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
