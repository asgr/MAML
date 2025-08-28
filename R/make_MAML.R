make_MAML = function(data, output='YAML', input='table', lookup=NULL, datamap=NULL, ...){

  i = j = NULL

  foreach(j = 1:length(lookup))%do%{
    match_by = lookup[[j]]$match_by

    if(is.null(match_by)){
      match_by = 'any'
    }

    pattern = lookup[[j]]$pattern

    if(match_by == 'any' | match_by == 'all'){NULL}#do nothing
    if(match_by == 'exact'){lookup[[j]]$pattern = paste0('^',pattern , '$')}
    if(match_by == 'prefix'){lookup[[j]]$pattern = paste0('^', pattern)}
    if(match_by == 'suffix'){lookup[[j]]$pattern = paste0(pattern, '$')}
    if(match_by == 'both'){lookup[[j]]$pattern = paste0('^', pattern,'|', pattern, '$')}
  }

  if(input == 'table'){
    temp_schema = arrow::schema(data)$fields
    col_names = names(data)
    fields = foreach(i = 1:dim(data)[2])%do%{
      unit = NULL
      description = NULL
      ucd = NULL

      data_type = if(is.null(temp_schema)){
        class(data[[i]])
      }else{
        temp_schema[[i]]$type$ToString()
      }

      if(!is.null(datamap)){
        temp_data_type = data_type
        data_type = .dataype_map(temp_data_type, datamap)

        if(data_type == 'error'){
          stop('Unsupported data type: ', temp_data_type)
        }

        if(data_type == 'missing'){
          stop('Unrecognised data type: ', temp_data_type)
        }
      }

      if(!is.null(lookup)){
        foreach(j = 1:length(lookup))%do%{
          check = grepl(lookup[[j]]$pattern, col_names[i], ignore.case = isTRUE(lookup[[j]]$ignore_case))

          if(check){
            if(is.null(unit) & !is.null(lookup[[j]]$unit)){
              #Take the first unit that matches (adding more don't make sense)
              unit = lookup[[j]]$unit
            }
            if(!is.null(lookup[[j]]$description)){
              #Concat descriptions together (space sep):
              description = paste(c(description, lookup[[j]]$description), collapse=' ')
            }
            if(!is.null(lookup[[j]]$ucd)){
              #Concat ucd together:
              ucd = paste(c(ucd,lookup[[j]]$ucd), collapse=';')
            }
          }
        }
      }

      list(
        name = col_names[i],
        unit = unit,
        description = description,
        ucd = ucd,
        data_type = data_type
      )
    }
  }else if(input == 'meta'){
    fields = apply(data, MARGIN=1, as.list)
  }else{
    stop('input must be table or meta!')
  }

  header = list(
    survey = "Survey Name",
    dataset = "Dataset Name",
    table = "Table Name",
    version = "0.0",
    date = as.character(Sys.Date()),
    author = "Lead Author <email>",
    coauthors = list(
      "Co-Author 1 <email1>",
      "Co-Author 2 <email2>"
    ),
    depend = list(
      "Dataset 1 this depends on [optional]",
      "Dataset 2 this depends on [optional]"
    ),
    comment = list(
      "Something interesting about the data [optional]",
      "Something else [optional]"
    ),
    fields = fields
  )

  dots = list(...)

  if(length(dots) > 0){
    for(i in 1:length(dots)){
      header[[names(dots)[i]]] = dots[[i]]
    }
  }

  if(tolower(output) == 'yaml' | tolower(output) == 'maml'){
    header = yaml::as.yaml(header)
    header = gsub(": ''\n", ": \n", header)
    header = gsub(": ~\n", ": \n", header)
    header = gsub(": .na\n", ": \n", header)
    header = gsub(": .na.integer\n", ": \n", header)
    header = gsub(": .na.real\n", ": \n", header)
    header = gsub(": .na.character\n", ": \n", header)
    header = gsub(": .nan\n", ": \n", header)
  }else if(tolower(output) == 'list'){
    #do nothing
  }else{
    stop('output type must be maml or list')
  }

  return(header)
}

.dataype_map = function(input, map){
  output = 'missing'
  for(check in map){
    if(tolower(input) %in% tolower(check$input)){return(check$output)}
  }
}
