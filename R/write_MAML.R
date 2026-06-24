write_MAML = function(MAML, filename='temp.maml', table=NULL, input='MAML', output='MAML', ...){
  if(input == 'list' & inherits(MAML, 'list')){
    MAML = yaml::as.yaml(MAML)
    MAML = gsub(": ''\n", ": \n", MAML)
    MAML = gsub(": ~\n", ": \n", MAML)
    MAML = gsub(": .na\n", ": \n", MAML)
    MAML = gsub(": .na.integer\n", ": \n", MAML)
    MAML = gsub(": .na.real\n", ": \n", MAML)
    MAML = gsub(": .na.character\n", ": \n", MAML)
    MAML = gsub(": .nan\n", ": \n", MAML)
    input = 'maml'
  }

  if(!is.character(MAML)){
    stop('MAML input is not in the expected format')
  }

  if(tolower(input) == 'maml' & tolower(output) == 'maml'){
    cat(MAML, file=filename)
  }else if(tolower(input) == 'maml' & tolower(output) == 'parquet'){
    table = arrow::as_arrow_table(table)
    table$metadata$maml = MAML
    arrow::write_parquet(table, filename, ...)
  }else{
    stop('MAML input is not in the expected format')
  }

}
