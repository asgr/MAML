read_MAML = function(file='test.maml', output='list', ...){
  if(output == 'list'){
    temp = read_yaml(file, ...)
  }else if(tolower(output) == 'maml' | tolower(output) == 'yaml'){
    temp = readLines(file, ...)
    temp = paste(temp, collapse = "\n")
    temp = paste0(temp, '\n')
  }

  return(temp)
}
