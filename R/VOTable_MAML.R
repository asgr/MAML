# VOTable data type to MAML data type lookup
.votable_to_maml_datatype = function(vot_type) {
  switch(tolower(vot_type),
    'boolean'   = 'boolean',
    'bit'       = 'boolean',
    'unsignedbyte' = 'uint8',
    'short'     = 'int16',
    'int'       = 'int32',
    'long'      = 'int64',
    'float'     = 'float32',
    'single'    = 'float32',
    'double'    = 'float64',
    'char'      = 'string',
    'unicodechar' = 'string',
    # fallback: return as-is
    vot_type
  )
}

# MAML data type to VOTable data type lookup
.maml_to_votable_datatype = function(maml_type) {
  switch(tolower(maml_type),
    'boolean'   = 'boolean',
    'bool'      = 'boolean',
    'uint8'     = 'unsignedByte',
    'int8'      = 'short',
    'int16'     = 'short',
    'uint16'    = 'int',
    'int32'     = 'int',
    'uint32'    = 'long',
    'int64'     = 'long',
    'uint64'    = 'long',
    'float'     = 'float',
    'float32'   = 'float',
    'float64'   = 'double',
    'double'    = 'double',
    'string'    = 'char',
    'utf8'      = 'char',
    'large_utf8'= 'char',
    'character' = 'char',
    # fallback
    maml_type
  )
}

VOTable_to_MAML = function(meta_col, meta_tab = NULL, MAML_version = 1.0, output = 'list', ...) {
  i = NULL

  if (!is.data.frame(meta_col)) {
    stop('meta_col must be a data.frame (e.g. as returned by read_VOTable with meta_col_read=TRUE)')
  }

  # Normalise column names to lower-case for robust matching
  col_lc = tolower(names(meta_col))

  .get_col = function(candidates) {
    idx = match(candidates, col_lc)
    idx = idx[!is.na(idx)]
    if (length(idx) == 0L) return(rep(NA_character_, nrow(meta_col)))
    meta_col[[idx[1]]]
  }

  vot_name      = .get_col(c('name'))
  vot_unit      = .get_col(c('unit'))
  vot_descrip   = .get_col(c('description', 'descrip', 'info'))
  vot_ucd       = .get_col(c('ucd'))
  vot_datatype  = .get_col(c('datatype', 'data_type', 'type'))
  vot_arraysize = .get_col(c('arraysize', 'array_size'))

  fields = foreach(i = seq_len(nrow(meta_col))) %do% {
    vtype = if (is.na(vot_datatype[i])) NA_character_ else as.character(vot_datatype[i])
    maml_type = if (is.na(vtype)) NA_character_ else .votable_to_maml_datatype(vtype)

    is_string = !is.na(vtype) && tolower(vtype) %in% c('char', 'unicodechar')

    raw_arraysize = vot_arraysize[i]
    array_size_val = NULL
    col_size_val   = NULL

    if (!is.na(raw_arraysize)) {
      # '*' or '*+N' means variable-length; treat as array_size for strings only
      if (grepl('[*]', as.character(raw_arraysize))) {
        if (is_string) {
          array_size_val = as.character(raw_arraysize)
        }
        # for numeric types a variable-length arraysize becomes col_size = NULL in MAML
      } else {
        sz = suppressWarnings(as.integer(raw_arraysize))
        if (!is.na(sz)) {
          if (is_string) {
            array_size_val = sz   # max string length
          } else if (MAML_version >= 1.2) {
            col_size_val = sz     # vector column size (v1.2+)
            # v1.0/v1.1 have no col_size field; numeric arraysize is dropped
          }
        }
      }
    }

    field = list(
      name       = if (is.na(vot_name[i]))    NULL else as.character(vot_name[i]),
      unit       = if (is.na(vot_unit[i]))    NULL else as.character(vot_unit[i]),
      info       = if (is.na(vot_descrip[i])) NULL else as.character(vot_descrip[i]),
      ucd        = if (is.na(vot_ucd[i]))     NULL else as.character(vot_ucd[i]),
      data_type  = maml_type,
      array_size = array_size_val
    )

    if (MAML_version >= 1.2) {
      field$col_size = col_size_val
    }

    field
  }

  # Table-level description: use meta_tab when provided, otherwise keep placeholder
  tab_description = if (!is.null(meta_tab) && nchar(meta_tab) > 0) {
    as.character(meta_tab)
  } else {
    "Recommended short description of the table"
  }

  MAML = list(
    survey      = "Optional survey name",
    dataset     = "Recommended dataset name",
    table       = "Required table name",
    version     = "Required version (string, integer, or float)",
    date        = as.character(Sys.Date()),
    author      = "Required lead author name <email>",
    coauthors   = list("Optional coauthor name <email1>", "... <...>"),
    DOIs        = list(list(DOI = 'Valid DOI', type = 'DOI type')),
    depends     = list(list(survey = 'Dependent survey', dataset = 'Dependent dataset',
                            table = 'Dependent table', version = 'Dependent table version')),
    description = tab_description,
    comments    = list("Optional comment or interesting fact", "..."),
    license     = "Recommended license for the dataset / table",
    keywords    = list("Optional keyword tag", "..."),
    MAML_version = MAML_version,
    fields      = fields
  )

  dots = list(...)
  if (length(dots) > 0) {
    for (nm in names(dots)) {
      MAML[[nm]] = dots[[nm]]
    }
  }

  if (tolower(output) %in% c('maml', 'yaml')) {
    return(list_to_MAML(MAML))
  } else if (tolower(output) == 'list') {
    return(MAML)
  } else {
    stop("output must be 'MAML' or 'list'")
  }
}

MAML_to_VOTable = function(MAML, ...) {
  i = NULL

  if (inherits(MAML, 'MAML') | (is.character(MAML) & length(MAML) == 1L)) {
    MAML = MAML_to_list(MAML)
  }

  if (!is.list(MAML) || is.null(MAML$fields)) {
    stop('MAML must be a list or MAML object containing a $fields element')
  }

  maml_version = if (!is.null(MAML$MAML_version)) MAML$MAML_version else 1.0

  rows = foreach(i = MAML$fields) %do% {
    name_val     = if (!is.null(i$name))       i$name       else NA_character_
    unit_val     = if (!is.null(i$unit))        i$unit       else NA_character_
    descrip_val  = if (!is.null(i$info))        i$info       else NA_character_
    ucd_val      = if (!is.null(i$ucd)) {
      ucd_raw = i$ucd
      if (length(ucd_raw) > 1) paste(ucd_raw, collapse = ';') else ucd_raw
    } else {
      NA_character_
    }
    maml_type    = if (!is.null(i$data_type))   i$data_type  else NA_character_
    vot_type     = if (!is.na(maml_type)) .maml_to_votable_datatype(maml_type) else NA_character_

    is_string = !is.null(i$data_type) && tolower(i$data_type) %in%
                  c('string', 'utf8', 'large_utf8', 'character')

    # Determine Arraysize:
    # - for string types: use array_size
    # - for vector columns (v1.2 col_size): use col_size
    arraysize_val = NA

    if (is_string && !is.null(i$array_size)) {
      arraysize_val = i$array_size
    }

    if (maml_version >= 1.2 && !is.null(i$col_size)) {
      col_sz = suppressWarnings(as.integer(i$col_size))
      # col_size=1 means a scalar column; only write Arraysize when the
      # column is genuinely multi-element (col_size > 1).
      if (!is.na(col_sz) && col_sz > 1L) {
        arraysize_val = col_sz
      }
    }

    data.frame(
      Name        = name_val,
      Unit        = unit_val,
      Description = descrip_val,
      UCD         = ucd_val,
      Datatype    = vot_type,
      Arraysize   = if (identical(arraysize_val, NA)) NA_character_ else as.character(arraysize_val),
      stringsAsFactors = FALSE
    )
  }

  meta_col = do.call(rbind, rows)

  # Attach table-level description as meta_tab attribute, matching the convention
  # used by VOTableR's read_VOTable (which stores it as attr(table, 'meta_tab'))
  meta_tab = if (!is.null(MAML$description) && nchar(MAML$description) > 0) {
    as.character(MAML$description)
  } else {
    NULL
  }
  attr(meta_col, 'meta_tab') = meta_tab

  return(meta_col)
}
