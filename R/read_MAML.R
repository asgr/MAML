read_MAML = function(filename='test.maml', output='list', ...){
  MAML = read_yaml(filename, ...)

  if(tolower(output) == 'maml' | tolower(output) == 'yaml'){
    return(list_to_MAML(MAML))
  }else if(tolower(output) == 'list'){
    return(MAML)
  }else{
    stop('Output type must be MAML or list!')
  }
}

MAML_to_list = function(MAML){
  if(!inherits(MAML, 'MAML')){
    warning('MAML input does not have class MAML')
    if(!is.character(MAML) | length(MAML) != 1L){
      stop('MAML input is not a scalar character!')
    }
  }
  return(read_yaml(text=MAML))
}

list_to_MAML = function(x){
  MAML = as.yaml(x)
  MAML = gsub(": ''\n", ": \n", MAML)
  MAML = gsub(": ~\n", ": \n", MAML)
  MAML = gsub(": .na\n", ": \n", MAML)
  MAML = gsub(": .na.integer\n", ": \n", MAML)
  MAML = gsub(": .na.real\n", ": \n", MAML)
  MAML = gsub(": .na.character\n", ": \n", MAML)
  MAML = gsub(": .nan\n", ": \n", MAML)
  class(MAML) = c('MAML', class(MAML))
  return(MAML)
}
