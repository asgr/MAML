make_MAML = function(data, output='YAML', input='table', dataset='dataset', lookup=NULL, ...){

  i = j = NULL

  if(input == 'table'){
    temp_schema = arrow::schema(data)$fields
    col_names = names(data)
    fields = foreach(i = 1:dim(data)[2])%do%{
      unit = NULL
      description = NULL
      ucd = NULL

      if(!is.null(lookup)){
        foreach(j = 1:length(lookup))%do%{
          pattern = lookup[[j]]$pattern
          match_by = lookup[[j]]$match_by

          if(is.null(match_by)){
            match_by = 'any'
          }

          if(match_by == 'any' | match_by == 'all'){pattern = pattern}
          if(match_by == 'exact'){pattern = paste0('^', pattern, '$')}
          if(match_by == 'prefix'){pattern = paste0('^', pattern)}
          if(match_by == 'suffix'){pattern = paste0(pattern, '$')}
          if(match_by == 'both'){pattern = paste0('^', pattern,'|', pattern, '$')}
          
          if(is.null(lookup[[j]]$ignore_case)){
            ignore = FALSE
          }else{
            ignore = lookup[[j]]$ignore_case
          }

          check = grepl(pattern, col_names[i], ignore.case=ignore)

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
        data_type = if(is.null(temp_schema)){
          switch(class(data[[i]])[1],
                 integer = "int32",
                 integer64 = "int64",
                 numeric = "double",
                 character = "string",
                 logical = 'bool',
                 "char")
        }else{
          temp_schema[[i]]$type$ToString()
        }
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

  names(header)[2] = dataset
  header[[2]] = paste(dataset,'Name')

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
