\name{make_MAML}
\alias{make_MAML}
\title{Generate MAML: Metadata yAML}
\description{
  Creates a metadata structure (MAML) based on the columns and types of a given data.frame, Parquet file or Arrow Dataset.
  Optionally returns the metadata as a YAML string, which is the MAML file format.
}
\usage{
make_MAML(data, output = 'MAML', input = 'table',
  fields_optional = c('unit', 'info', 'ucd', 'array_size', 'col_size', 'qc'),
  lookup = NULL, datamap = NULL, qc_min = 'get', qc_max = 'get', qc_null = 'Null',
  ucd_collapse = FALSE, MAML_version = 1.0, vec_col = NULL, ...)
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
  \item{ucd_collapse}{
Logical; should the per field UCD output be collapsed to IVOA standard semi-colon separated field, so the YAML vector [meta.id, meta.main] would instead be 'meta.id;meta.main' scalar. This is perhaps useful when mostly interacting with software that expects IVOA format UCDs.
}
  \item{MAML_version}{
Numeric scalar; specify the version of MAML to target. This is mostly a convenience, since it is still a requirement that the user makes sures the additional entries (via \dots) are compatible with the MAML version. A special case is \option{MAML_version} = 1.2, since that will create the extra field argument 'col_size' which will specify the number of vector elements in each cell of the column (i.e. col_size > 1 means we have a vector column).
}
  \item{vec_col}{
Character vector; used to specify known vector columns when using \option{MAML_version} = 1.2. This is only required when the vector columns are a series of scalar columns with names like example_1, example_2 ... example_N etc, where the \option{vec_col} name is the part before the column number specifier ('example' in this case). If the input \option{data} is already structured as vector columns internally then this should not be specified (see Examples).
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

#For IVOA style UCD entries:
cat(make_MAML(df, lookup=lookup, ucd_collapse=TRUE))

#The IVOA mode also creates nicer data.frame outputs:
meta2 = rbindlist(make_MAML(df, lookup=lookup, ucd_collapse=TRUE, output='list',
  fields_optional = c('unit', 'ucd'))$fields)
print(meta2)

#load datamap to target a set of datatypes:
datamap = read_yaml(system.file('extdata', 'datamap.yaml', package = "MAML"))
#this is what the file looks like
cat(as.yaml(datamap))

cat(make_MAML(df, datamap=datamap))

test_vec_dt1 = data.frame(
  ID=1:10,
  test = I(lapply(rep(2,10),runif)),
  filler = 11:20,
  other = I(lapply(rep(3,10),runif)),
  end = 21:30
)

cat(make_MAML(test_vec_dt1, MAML_version=1.2))

test_vec_dt2 = data.frame(
  ID = 1:10,
  test_1 = runif(10), test_2 = runif(10),
  filler = 11:20,
  other_1 = runif(10), other_2 = runif(10), other_3 = runif(10),
  end = 21:30
)

cat(make_MAML(test_vec_dt2, MAML_version=1.2, vec_col=c('test', 'other')))
}
