# MAML

MAML is a YAML based metadata format for tabular data. This package is a simple R interface to help create, read and write MAML files.

### Installation

To install the necessary dependencies, run:

```bash
install.packages("remotes")
remotes::install_github("asgr/MAML")
```

### Usage

A simple example using a toy table we want to create MAML metedata from:

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
