validate_MAML = function(MAML){
  if(inherits(MAML, 'MAML') | (is.character(MAML) & length(MAML) == 1L)){
    MAML = MAML_to_list(MAML)
  }
  schema_json = system.file('extdata', 'MAML_schema.json', package = "MAML")

  MAML_json = toJSON(MAML, pretty = TRUE, auto_unbox = TRUE, na = 'null')

  MAML_json = gsub('"unit": {}', '"unit": null', MAML_json, fixed = T)
  MAML_json = gsub('"info": {}', '"info": null', MAML_json, fixed = T)
  MAML_json = gsub('"ucd": {}', '"ucd": null', MAML_json, fixed = T)
  MAML_json = gsub('"array_size": {}', '"array_size": null', MAML_json, fixed = T)
  MAML_json = gsub('"min": {}', '"min": null', MAML_json, fixed = T)
  MAML_json = gsub('"max": {}', '"max": null', MAML_json, fixed = T)
  MAML_json = gsub('"miss": {}', '"miss": null', MAML_json, fixed = T)

  return(json_validate(MAML_json, schema_json, verbose = TRUE, engine='ajv'))
}
