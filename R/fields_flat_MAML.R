fields_flat_MAML = function(MAML, fields_keep = c('name', 'unit', 'info', 'ucd', 'data_type', 'array_size', 'qc')){
  if(inherits(MAML, 'MAML') | (is.character(MAML) & length(MAML) == 1L)){
    MAML = MAML_to_list(MAML)
  }

  i = NULL
  meta_col = rbindlist(foreach(i = MAML$fields)%do%{lapply(i, paste, collapse=';')}, fill=TRUE)
  setDF(meta_col)
  return(meta_col[,fields_keep])
}
