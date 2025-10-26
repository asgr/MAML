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
    return(current_valid)
  }

  valid_UCD = UCDWords$new()

  for(i in MAML$fields){
    if(!is.null(i$ucd)){
      if(!valid_UCD$check_ucd(i$ucd)){
        message('Failing UCD name validation!')
        message('Non valid UCDs: ', paste(i$ucd[!(i$ucd %in% valid_UCD)], collapse=' '))
      }
    }
  }

  message('Passing UCD name validation!')

  message("Ain't nothing but MAML!")

  return(current_valid)
}
