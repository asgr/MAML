write_MAML = function(MAML, file='temp.maml', input='YAML'){
  if(input == 'list' & inherits(MAML, 'list')){
    MAML = yaml::as.yaml(MAML)
    MAML = gsub(": ''\n", ": \n", MAML)
    MAML = gsub(": ~\n", ": \n", MAML)
    MAML = gsub(": .na\n", ": \n", MAML)
    MAML = gsub(": .na.integer\n", ": \n", MAML)
    MAML = gsub(": .na.real\n", ": \n", MAML)
    MAML = gsub(": .na.character\n", ": \n", MAML)
    MAML = gsub(": .nan\n", ": \n", MAML)
    input = 'yaml'
  }

  if(tolower(input) == 'yaml' & is.character(MAML)){
    cat(MAML, file=file)
  }else{
    stop('MAML input is not in the expected format')
  }

}
