\name{read_MAML}
\alias{read_MAML}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
MAML Reader
}
\description{
Simple MAML reader, using the lower level \code{read_yaml} function to format the data.
}
\usage{
read_MAML(file = "test.maml", output = "list", ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{file}{
Character scalar; file read. Should usually end ".maml" (but perhaps sometimes ".yaml").
}
  \item{output}{
Character scalar; format of output from function. Either 'list' which is an R list stucture, or 'YAML' which is a character string (i.e. the full contents of the target MAML file).
}
  \item{\dots}{
Other arguments passes to read_yaml (\option{output} = 'list') or \code{\link{readLines}} (\option{output} = 'YAML').
}
}
\details{
This is a high-level interface to read the MAML from disk.
}
\value{
Output depends on the setting of \option{output}. Either \option{output} = 'list' which is an R list stucture, or \option{output} = 'YAML' which is a character string (i.e. the full contents of the target MAML file).
}
\author{
Aaron Robotham
}
\seealso{
\code{\link{make_MAML}}, \code{\link{write_MAML}}, \code{\link[yaml]{as.yaml}}
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
