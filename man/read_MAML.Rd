\name{read_MAML}
\alias{read_MAML}
\alias{MAML_to_list}
\alias{list_to_MAML}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
MAML Reader
}
\description{
Simple MAML reader and converter functions, using the lower level \code{read_yaml} function to format the data.
}
\usage{
read_MAML(filename = "test.maml", output = "list", ...)
MAML_to_list(MAML)
list_to_MAML(x)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{filename}{
Character scalar; file read. Should usually end ".maml" (but perhaps sometimes ".yaml").
}
  \item{output}{
Character scalar; format of output from function. Either 'list' which is an R list stucture, or 'MAML' which is a character string (i.e. the full contents of the target MAML file).
}
  \item{MAML}{
Character scalar; a class MAML string.
}
  \item{x}{
List; a MAML compatible list.
}
  \item{\dots}{
Other arguments passes to read_yaml (\option{output} = 'list') or \code{\link{readLines}} (\option{output} = 'YAML').
}
}
\details{
This is a high-level interface to read the MAML from disk.
}
\value{
For \code{read_MAML} output depends on the setting of \option{output}. Either \option{output} = 'list' which is an R list stucture, or \option{output} = 'MAML' which is a character string (i.e. the full contents of the target MAML file).

For \code{MAML_to_list} the output is a list.

For \code{list_to_MAML} the output is a class MAML string (scalar).
}
\author{
Aaron Robotham
}
\seealso{
\code{\link{make_MAML}}, \code{\link{write_MAML}}, \code{\link[yaml]{as.yaml}}
}
\examples{
example_default = read_MAML(system.file('extdata', 'example_default.maml',
  package = "MAML"), output='maml')
cat(example_default)
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
