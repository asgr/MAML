# MAML

MAML is a YAML based metadata format. This package is a simple R interface to help create, read and write MAML files.

## Installation

To install the necessary dependencies, run:

```bash
install.packages("remotes")
remotes::install_github("asgr/MAML")
```
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
