\name{VOTable_MAML}
\alias{VOTable_to_MAML}
\alias{MAML_to_VOTable}
\title{Convert Between VOTable Column Headers and MAML Fields}
\description{
  \code{VOTable_to_MAML} converts a VOTable column-header data frame (as returned
  by \code{read_VOTable} from the VOTableR package) into a MAML list or MAML-
  formatted string.

  \code{MAML_to_VOTable} converts the fields of a MAML list or MAML-formatted
  string into a VOTable column-header data frame suitable for passing to
  \code{write_VOTable}.

  Both functions handle the data-type vocabulary differences between the two
  formats, and map \code{array_size} (string max-length) and \code{col_size}
  (vector-column width, MAML v1.2) to and from the VOTable \code{arraysize}
  attribute.
}
\usage{
VOTable_to_MAML(meta_col, MAML_version = 1.0, output = 'list', ...)

MAML_to_VOTable(MAML, ...)
}
\arguments{
  \item{meta_col}{
Data frame; the per-column metadata returned by \code{read_VOTable(...,
meta_col_read = TRUE)}.  Expected columns (case-insensitive): \code{Name},
\code{Unit}, \code{Description}, \code{UCD}, \code{Datatype},
\code{Arraysize}.
}
  \item{MAML_version}{
Numeric scalar; which MAML version to target (1.0, 1.1, or 1.2).  When
\code{MAML_version >= 1.2} a numeric \code{arraysize} on a non-string column
is interpreted as a vector-column width and mapped to the \code{col_size}
field.
}
  \item{output}{
Character scalar; \code{'list'} (default) returns a named R list,
\code{'MAML'} or \code{'yaml'} returns a MAML-formatted YAML string.
}
  \item{MAML}{
Character scalar or List; the MAML whose fields should be converted.  Accepts
a raw MAML string (class \code{MAML}), a plain character scalar, or a plain
list as returned by \code{MAML_to_list} / \code{read_MAML(..., output='list')}.
}
  \item{\dots}{
Additional named arguments passed to the top-level MAML list (for
\code{VOTable_to_MAML}) or currently ignored (for \code{MAML_to_VOTable}).
}
}
\details{
\strong{Data-type mapping}

The two formats use different type vocabularies.  The mapping applied is:

\tabular{ll}{
  \strong{VOTable datatype} \tab \strong{MAML data_type} \cr
  \code{boolean} / \code{bit}        \tab \code{boolean}   \cr
  \code{unsignedByte}                \tab \code{uint8}     \cr
  \code{short}                       \tab \code{int16}     \cr
  \code{int}                         \tab \code{int32}     \cr
  \code{long}                        \tab \code{int64}     \cr
  \code{float} / \code{single}       \tab \code{float32}   \cr
  \code{double}                      \tab \code{float64}   \cr
  \code{char} / \code{unicodeChar}   \tab \code{string}    \cr
}

The reverse mapping (MAML → VOTable) follows the same table in the opposite
direction.

\strong{Array sizes and vector columns}

\itemize{
  \item For string/char columns: the VOTable \code{arraysize} attribute (e.g.
    \code{"50"} or \code{"*"}) is stored in the MAML \code{array_size} field
    and vice-versa.

  \item For numeric/integer columns with MAML version >= 1.2: a numeric
    \code{arraysize} value in the VOTable header is mapped to the MAML
    \code{col_size} field (indicating a fixed-width vector column).  When
    converting in the reverse direction, a \code{col_size > 1} is written out
    as the VOTable \code{Arraysize}.

  \item For MAML v1.0 and v1.1 the \code{col_size} field does not exist;
    vector-column information carried in a numeric VOTable \code{arraysize} is
    therefore silently dropped on that conversion path.
}
}
\value{
\code{VOTable_to_MAML}: a named list (MAML structure) when
\code{output = 'list'}, or a MAML-formatted character string when
\code{output = 'MAML'}.

\code{MAML_to_VOTable}: a data frame with columns \code{Name},
\code{Unit}, \code{Description}, \code{UCD}, \code{Datatype},
\code{Arraysize}.  Rows correspond one-to-one to the MAML \code{fields}
entries.
}
\author{
Aaron Robotham
}
\seealso{
\code{\link{make_MAML}}, \code{\link{read_MAML}}, \code{\link{fields_flat_MAML}}
}
\examples{
# Build a minimal VOTable meta_col data frame
meta_col = data.frame(
  Name        = c("RA", "Dec", "Mag", "SpType"),
  Unit        = c("deg", "deg", "mag", NA),
  Description = c("Right Ascension", "Declination", "Magnitude", "Spectral type"),
  UCD         = c("pos.eq.ra", "pos.eq.dec", "phot.mag", NA),
  Datatype    = c("double", "double", "float", "char"),
  Arraysize   = c(NA, NA, NA, "10"),
  stringsAsFactors = FALSE
)

# Convert to MAML (list)
maml_list = VOTable_to_MAML(meta_col, MAML_version = 1.0)
str(maml_list$fields)

# Convert back to VOTable header
meta_col2 = MAML_to_VOTable(maml_list)
print(meta_col2)

# Round-trip check: field names and types are preserved
stopifnot(identical(meta_col$Name,     meta_col2$Name))
stopifnot(identical(meta_col$Datatype, meta_col2$Datatype))

# MAML v1.2 with a vector column (arraysize interpreted as col_size)
meta_col_vec = data.frame(
  Name        = c("ID", "flux"),
  Unit        = c(NA, "Jy"),
  Description = c("Identifier", "Flux vector"),
  UCD         = c(NA, "phot.flux"),
  Datatype    = c("int", "float"),
  Arraysize   = c(NA, "5"),
  stringsAsFactors = FALSE
)

maml12 = VOTable_to_MAML(meta_col_vec, MAML_version = 1.2)
# col_size should be 5 for the flux column
stopifnot(maml12$fields[[2]]$col_size == 5L)

meta_col_vec2 = MAML_to_VOTable(maml12)
stopifnot(meta_col_vec2$Arraysize[2] == "5")
}
