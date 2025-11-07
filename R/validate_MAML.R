validate_MAML = function(MAML, schema='v1.0'){
  if(inherits(MAML, 'MAML') | (is.character(MAML) & length(MAML) == 1L)){
    MAML = MAML_to_list(MAML)
  }

  if(schema == 'v1.0'){
    schema = system.file('extdata', 'MAML_schema_v1p0.json', package = "MAML")
  }else if(schema == 'v1.1'){
    schema = system.file('extdata', 'MAML_schema_v1p1.json', package = "MAML")
  }

  MAML_json = toJSON(MAML, pretty = TRUE, auto_unbox = TRUE, na = 'null')

  #Fill missing table meta with null
  MAML_json = gsub('"survey": {}', '"survey": null', MAML_json, fixed = T)
  MAML_json = gsub('"dataset": {}', '"dataset": null', MAML_json, fixed = T)
  MAML_json = gsub('"coauthors": {}', '"coauthors": null', MAML_json, fixed = T)
  MAML_json = gsub('"DOIs": {}', '"DOIs": null', MAML_json, fixed = T)
  MAML_json = gsub('"depends": {}', '"depends": null', MAML_json, fixed = T)
  MAML_json = gsub('"description": {}', '"description": null', MAML_json, fixed = T)
  MAML_json = gsub('"license": {}', '"license": null', MAML_json, fixed = T)
  MAML_json = gsub('"keywords": {}', '"keywords": null', MAML_json, fixed = T)

  #Fill missing fields meta with null
  MAML_json = gsub('"unit": {}', '"unit": null', MAML_json, fixed = T)
  MAML_json = gsub('"info": {}', '"info": null', MAML_json, fixed = T)
  MAML_json = gsub('"ucd": {}', '"ucd": null', MAML_json, fixed = T)
  MAML_json = gsub('"data_type": {}', '"data_type": null', MAML_json, fixed = T)
  MAML_json = gsub('"array_size": {}', '"array_size": null', MAML_json, fixed = T)
  MAML_json = gsub('"min": {}', '"min": null', MAML_json, fixed = T)
  MAML_json = gsub('"max": {}', '"max": null', MAML_json, fixed = T)
  MAML_json = gsub('"miss": {}', '"miss": null', MAML_json, fixed = T)

  current_valid = json_validate(MAML_json, schema, verbose = TRUE, engine='ajv')

  if(isTRUE(current_valid)){
    message('Passing JSON schema validation!')
  }else{
    message('Failing JSON schema validation!')
    return(FALSE)
  }

  valid_UCD = read.table(system.file('extdata', 'valid_UCD_v1p6_extra.dat', package = "MAML"),
                         sep='|', comment.char = '#', strip.white = TRUE, col.names = c("letter", "ucd", "description"))

  for(i in seq_along(MAML$fields)){
    UCDs = MAML$fields[[i]]$ucd
    if(!is.null(UCDs)){
      if(isFALSE(ucd_validate(UCDs, valid_UCD))){
        message('Failing UCD name validation!')
        return(FALSE)
      }
    }
  }

  message('Passing UCD name validation!')

  message("Ain't nothing but MAML!")

  return(TRUE)
}

ucd_validate = function(UCDs, valid_UCD = NULL){

  if(is.null(valid_UCD)){
    valid_UCD = read.table(system.file('extdata', 'valid_UCD_v1p6_extra.dat', package = "MAML"),
                           sep='|', comment.char = '#', strip.white = TRUE, col.names = c("letter", "ucd", "description"))
  }

  primary = tolower(valid_UCD[valid_UCD$letter != 'S','ucd'])
  secondary = tolower(valid_UCD[valid_UCD$letter != 'P','ucd'])

  ucd_loc = tolower(UCDs)

  passing = TRUE

  if(any(!(ucd_loc %in% valid_UCD$ucd))){
    message('Failing UCD name validation!')
    message('Non valid UCDs: ', paste(ucd_loc[!(ucd_loc %in% valid_UCD$ucd)], collapse=' '))
    passing = FALSE
  }

  for(j in seq_along(ucd_loc)){
    if(j == 1){
      if(!(ucd_loc[j] %in% primary)){
        message('Failing UCD name validation!')
        message('Non valid primary UCD: ', ucd_loc[j])
        passing = FALSE
      }
    }else{
      if(!(ucd_loc[j] %in% secondary)){
        message('Failing UCD name validation!')
        message('Non valid secondary UCD: ', ucd_loc[j])
        passing = FALSE
      }
    }
  }

  return(passing)
}
