\name{fields_flat_MAML}
\alias{fields_flat_MAML}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Flatten MAML Fields into Table
}
\description{
Create a flat (data.frame) view of the MAML fields. This can be useful for processing and QC.
}
\usage{
fields_flat_MAML(MAML, fields_keep = c("name", "unit", "info", "ucd", "data_type",
  "array_size", "qc"))
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{MAML}{
Character scalar or List; the MAML we want to flatten the Fields of.
}
  \item{fields_keep}{
Character vector; the fields we want present in the output catalogue.
}
}
\details{
The 'ucd' and 'qc' sub fields will be concatenated into ';' separated strings and exist in columns named 'ucd' and 'qc' if relevant.
}
\value{
Data.frame / Data.table
}
\author{
Aaron Robotham
}

\seealso{
\code{\link{make_MAML}}
}
\examples{
example_lookup_datamap = read_MAML(system.file('extdata', 'example_lookup_datamap.maml',
  package = "MAML"), output='MAML')
fields_flat_MAML(example_lookup_datamap)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory (show via RShowDoc("KEYWORDS")):
% \keyword{ ~kwd1 }
% \keyword{ ~kwd2 }
% Use only one keyword per line.
% For non-standard keywords, use \concept instead of \keyword:
% \concept{ ~cpt1 }
% \concept{ ~cpt2 }
% Use only one concept per line.
