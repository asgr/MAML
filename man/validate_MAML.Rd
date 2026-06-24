\name{validate_MAML}
\alias{validate_MAML}
\alias{ucd_validate}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Validate a MAML
}
\description{
Can validate wither a MAML string or list object aginst the official schema JSON specification.
}
\usage{
validate_MAML(MAML, schema = 'v1.0')
ucd_validate(UCDs, valid_UCD = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{MAML}{
Character scalar or List; the MAML we want to validate against the official schema.
}
  \item{schema}{
Character scalar, if 'v1.x'  then it will use the 'v1.x' MAML schema that is included with the package (current options: v1.0, v1.1). Otherwise the string should be a valid schema you wish to test against. In the latter case, this should probably be a stricter version of the default (see Examples).
}
  \item{UCDs}{
Character vector; UCDs to be checked. These should be in the correct primary (first) and secondard (later) order.
}
  \item{valid_UCD}{
Data.frame; a table of UCDs to validate against. If NULL then this is loaded from the valid_UCD_v1.6_extra package default. This is really here for speed so we can load the table once externally when running \code{ucd_validate} lots of times on a large MAML in \code{validate_MAML}. For interactive uses probably just leave as NULL.
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

#to check the default validation schema directly:

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
