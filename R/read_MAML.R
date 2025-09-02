read_MAML = function(filename='test.maml', output='list', ...){
  if(output == 'list'){
    temp = read_yaml(filename, ...)
  }else if(tolower(output) == 'maml' | tolower(output) == 'yaml'){
    temp = readLines(filename, ...)
    temp = paste(temp, collapse = "\n")
    temp = paste0(temp, '\n')
  }

  return(temp)
}
