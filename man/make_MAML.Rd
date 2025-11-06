\name{make_MAML}
\alias{make_MAML}
\title{Generate MAML: Metadata yAML}
\description{
  Creates a metadata structure (MAML) based on the columns and types of a given data.frame, Parquet file or Arrow Dataset.
  Optionally returns the metadata as a YAML string, which is the MAML file format.
}
\usage{
make_MAML(data, output = 'MAML', input = 'table',
  fields_optional = c('unit', 'info', 'ucd', 'array_size', 'qc'),
  lookup = NULL, datamap = NULL, qc_min = 'get', qc_max = 'get', qc_null = 'Null', ...)
}
\arguments{
  \item{data}{
\code{data.frame}, \code{tibble} or Arrow Dataset containing the table or meta data to describe.
}
  \item{input}{
Character scalar; input type. Allowed are 'table' (a 2D view of the data table) or 'meta_col' (a data.frame view of fields meta data, see Examples).
}
  \item{fields_optional}{
Character vector; which of the optional MAML field entries you wish to present in the generated skeleton.
}
  \item{output}{
Character scalar; output type. If \code{MAML}, returns the metadata as a MAML-formatted string. If \code{list}, returns a named list.
}
  \item{lookup}{
List; optional lookup matching list to create default entries in the MAML. See Examples.
}
  \item{datamap}{
List; optional data type matching list. See Examples.
}
  \item{qc_min}{
Scalar; if 'get' then will find the min of the column for qc_min, otherwise the output will inherit the value of \option{qc_min}.
}
  \item{qc_max}{
Scalar; if 'get' then will find the max of the column for qc_max, otherwise the output will inherit the value of \option{qc_min}.
}
  \item{qc_null}{
Scalar; what to specify for the missing data type of the column. This likely depends on the file format being used, but for Parquet it is probably best to set as the default ('Null').
}
  \item{\dots}{
Modify default entries (see Examples).
}
}
\details{
  This function inspects the schema of the input data using the \code{arrow} package (if available),
  and constructs a metadata header including dataset name, version, authorship, dependencies, and
  a description of each field. Field types are inferred either from the \code{arrow::schema()} or
  from base R classes.

  The resulting MAML metadata is suitable for use in data documentation, archiving, or interoperability
  with systems that consume YAML metadata.
}
\value{
  A character string containing MAML-formatted metadata if \code{output} = 'MAML', otherwise a named list.
}
\author{
  Aaron Robotham
}
\seealso{
  \code{\link{read_MAML}}, \code{\link{write_MAML}}, \code{\link[yaml]{as.yaml}}, \code{\link[arrow]{schema}}
}
\examples{
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
cat(make_MAML(df, dataset = 'GroupFinding'))
cat(make_MAML(df, table = 'Example Name'))
cat(make_MAML(df, table = 'Example Name', comment = NULL)) #delete comment field
cat(make_MAML(df, table = 'Example Name', comment = list('Comment 1', 'Comment 2')))

ds = open_dataset(system.file('extdata', 'example.parquet', package = "MAML"))

cat(make_MAML(ds))

#The data.frame view of the fields meta data:
meta = rbindlist(make_MAML(df, output='list', fields_optional = c('unit', 'ucd'))$fields)
print(meta)

#Convert back to the MAML format:
cat(make_MAML(meta, input = 'meta_col'))

#load lookup to fill in more data automatically:
lookup = read_yaml(system.file('extdata', 'lookup.yaml', package = "MAML"))
#this is what the file looks like
cat(as.yaml(lookup))

cat(make_MAML(df, lookup=lookup))

#load datamap to target a set of datatypes:
datamap = read_yaml(system.file('extdata', 'datamap.yaml', package = "MAML"))
#this is what the file looks like
cat(as.yaml(datamap))

cat(make_MAML(df, datamap=datamap))
}
