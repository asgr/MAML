\name{validate_MAML}
\alias{validate_MAML}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Validate a MAML
}
\description{
Can validate wither a MAML string or list object aginst the official schema JSON specification.
}
\usage{
validate_MAML(MAML)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{MAML}{
Character scalar or List; the MAML we want to validate against the official schema.
}
}
\details{
This uses the \code{\link[jsonvalidate]{json_validate}} to validate the JSON schema included in the package.
}
\value{
Logical.

If it passes the validation it will just return TRUE, but if it fails it will return FALSE and attached the validation data.frame.
}
\author{
Aaron Robotham
}
\note{
We are slightly generous is allowing totally missing entires to be considered as NULL, which is not the default behavious of the json validator engine used.
}
\seealso{
\code{\link{make_MAML}}
}
\examples{
example_default = read_MAML(system.file('extdata', 'example_default.maml',
  package = "MAML"), output='list')
validate_MAML(example_default)

#to check the validation schema directly:

cat(readLines(system.file('extdata', 'MAML_schema.json', package = "MAML")), sep = "\n")
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
