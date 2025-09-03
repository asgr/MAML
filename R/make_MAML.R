make_MAML = function(data, output='MAML', input = 'table',
                     fields_optional = c('unit', 'info', 'ucd', 'array_size', 'qc'),
                     lookup = NULL, datamap = NULL, qc_null = 'Null', ...){

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
      info = NULL
      ucd = NULL
      array_size = NULL
      qc = NULL

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
            if(!is.null(lookup[[j]]$info)){
              #Concat info blocks together (space sep):
              info = c(info, lookup[[j]]$info)
            }
            if(!is.null(lookup[[j]]$ucd)){
              #Concat ucd together:
              ucd = c(ucd, lookup[[j]]$ucd)
            }
          }
        }
      }

      if('qc' %in% fields_optional & is.data.frame(data)){
        qc_min = min(data[[col_names[i]]], na.rm=TRUE)
        if(is.integer64(qc_min)){
          if(qc_min > -.Machine$integer.max & qc_min < .Machine$integer.max){
            qc_min = as.integer(qc_min)
          }else{
            qc_min = as.character(qc_min)
          }
        }

        qc_max = max(data[[col_names[i]]], na.rm=TRUE)
        if(is.integer64(qc_max)){
          if(qc_max > -.Machine$integer.max & qc_max < .Machine$integer.max){
            qc_max = as.integer(qc_max)
          }else{
            qc_max = as.character(qc_max)
          }
        }

        qc_null = qc_null
      }else{
        qc_min = NULL
        qc_max = NULL
        qc_null = NULL
      }

      temp_field = list(
        name = col_names[i],
        unit = unit,
        info = paste(info, collapse=' '),
        ucd = paste(unique(ucd), collapse=';'),
        data_type = data_type,
        array_size = array_size,
        qc = list(
          min = qc_min,
          max = qc_max,
          miss = qc_null
        )
      )

      return(temp_field[names(temp_field) %in% c('name', 'data_type', fields_optional)])
    }
  }else if(input == 'meta_col'){
    fields = apply(data, MARGIN=1, as.list)
  }else{
    stop('input must be table or meta_col')
  }

  MAML = list(
    survey = "Optional survey name",
    dataset = "Recommended dataset name",
    table = "Required table name",
    version = "Required version (string, integer, or float)",
    date = as.character(Sys.Date()),
    author = "Required lead author name <email>",
    coauthors = list(
      "Optional coauthor name <email1>",
      "... <...>"
    ),
    DOIs = list(
      "Optional DOI string",
      "..."
    ),
    depends = list(
      "Optional dataset dependency",
      "..."
    ),
    description = "Recommended short description of the table",
    comments = list(
      "Optional comment or interesting fact",
      "..."
    ),
    license = "Recommended license for the dataset / table",
    keywords = list(
      "Optional keyword tag",
      "..."
    ),
    fields = fields
  )

  dots = list(...)

  if(length(dots) > 0){
    for(i in 1:length(dots)){
      MAML[[names(dots)[i]]] = dots[[i]]
    }
  }

  if(tolower(output) == 'yaml' | tolower(output) == 'maml'){
    MAML = list_to_MAML(MAML)
  }else if(tolower(output) == 'list'){
    #do nothing
  }else{
    stop('Output type must be MAML or list!')
  }
  return(MAML)
}

.dataype_map = function(input, map){
  output = 'missing'
  for(check in map){
    if(tolower(input) %in% tolower(check$input)){return(check$output)}
  }
}
