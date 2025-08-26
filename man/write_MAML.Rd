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
write_MAML(MAML, file = "temp.maml", input = "YAML")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{MAML}{
List or character scalar; input MAML metadata (can be list or YAML string format).
}
  \item{file}{
Character scalar; file to write output to. Should end ".maml".
}
  \item{input}{
Character scalar; specify the input format. Either 'YAML' for a character string, of 'list' for an R list structure.
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
