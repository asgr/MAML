\name{merge_MAML}
\alias{merge_MAML}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
MAML Merging Tool
}
\description{
A convenience function to use metadata from a target secondary MAML to fill a primary one.
}
\usage{
merge_MAML(MAML_primary, MAML_secondary, prefer = "primary", output = "MAML")
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{MAML_primary}{
Character scalar or List; the MAML we want to populate with more information.
}
  \item{MAML_secondary}{
Character scalar or List; the MAML potentially containing additional information.
}
  \item{prefer}{
Which takes priority in the case where both have entires. Either 'primary' (default) or 'secondary'.
}
  \item{output}{
Character scalar; output type. If \code{MAML}, returns the metadata as a MAML-formatted string. If \code{list}, returns a named list.
}
}
\details{
The \option{MAML_secondary} can be much larger than the \option{MAML_primary} since scanning is done by name
}
\value{
List with the same skeleton structure as \option{MAML_primary}, but hopefully with more entries filled.
}
\author{
Aaron Robotham
}

\seealso{
\code{\link{make_MAML}}, ~~~
}
\examples{
example_primary = read_MAML(system.file('extdata', 'example_default.maml',
  package = "MAML"), output='list')
print(example_primary$fields[[1]]$info)

example_secondary = example_primary[-(1:3)] #deliberately remove some entries
example_secondary$fields[[1]]$info = 'Something new'

example_merge = merge_MAML(example_primary, example_secondary, output='list')
print(example_merge$fields[[1]]$info) #it has now been added
length(example_merge) == length(example_primary) #should be TRUE
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
