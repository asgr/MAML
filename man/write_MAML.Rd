\name{write_MAML}
\alias{write_MAML}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
MAML Writer
}
\description{
Simple MAML writer, using the lower level yaml function to format the data.
}
\usage{
write_MAML(MAML, filename = "temp.maml", table = NULL, input = 'MAML', output = 'MAML',
  ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{MAML}{
List or character scalar; input MAML metadata (can be list or MAML string format).
}
  \item{filename}{
Character scalar; filename to write output to. Should end ".maml".
}
  \item{table}{
Table, table that MAML should be inserted into. Can be any format that \code{arrow} can convert to and Arrow table (so data.frame, data.table, tibble all work).
}
  \item{input}{
Character scalar; specify the input format. Either 'MAML' for a character string, of 'list' for an R list structure.
}
  \item{output}{
Character scalar; specify the output format. Either 'MAML' for a character string standalone ".maml" text file, or "Parquet" for the MAML to be added to the metadata of Parquet file (will be inserted into metadata$maml). In the latter case \option{table} is required.
}
  \item{\dots}{
Dots to be passed to \code{write_parquet}.
}
}
\details{
This is a high-level interface to write the MAML to disk.
}
\value{
Run for the side effect of writing data to a file.
}
\author{
Aaron Robotham
}

\seealso{
\code{\link{make_MAML}}, \code{\link{read_MAML}}, \code{\link[yaml]{as.yaml}}
}
\examples{
# Nothing yet
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
