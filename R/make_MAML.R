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
      qc_min_loc = NULL
      qc_max_loc = NULL
      qc_null_loc = NULL

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
              if(is.null(info)){
                info = lookup[[j]]$info
              }else if(grepl(lookup[[j]]$info, info, fixed = TRUE) == FALSE){
                #check the new info is unique (otherwise do not add)
                info = c(info, lookup[[j]]$info)
              }
            }

            if(!is.null(lookup[[j]]$ucd)){
              #Concat ucd together:
              ucd = c(ucd, lookup[[j]]$ucd)
            }

            if(!is.null(lookup[[j]]$qc_min)){
              #Take first matching qc_min:
              qc_min_loc = lookup[[j]]$qc_min
            }

            if(!is.null(lookup[[j]]$qc_max)){
              #Take first matching qc_max:
              qc_max_loc = lookup[[j]]$qc_max
            }

            if(!is.null(lookup[[j]]$qc_null)){
              #Take first matching qc_null:
              qc_null_loc = lookup[[j]]$qc_null
            }
          }
        }
      }

      if('qc' %in% fields_optional & is.data.frame(data)){
        if(is.null(qc_min_loc)){
          print(lookup[[j]])
          qc_min_loc = min(data[[col_names[i]]], na.rm=TRUE)
          if(is.integer64(qc_min_loc)){
            if(qc_min_loc > -.Machine$integer.max & qc_min_loc < .Machine$integer.max){
              qc_min_loc = as.integer(qc_min_loc)
            }else{
              qc_min_loc = as.character(qc_min_loc)
            }
          }
        }

        if(is.null(qc_max_loc)){
          qc_max_loc = max(data[[col_names[i]]], na.rm=TRUE)
          if(is.integer64(qc_max_loc)){
            if(qc_max_loc > -.Machine$integer.max & qc_max_loc < .Machine$integer.max){
              qc_max_loc = as.integer(qc_max_loc)
            }else{
              qc_max_loc = as.character(qc_max_loc)
            }
          }
        }

        if(is.null(qc_null_loc)){
          qc_null_loc = qc_null
        }
      }else{
        qc_min_loc = NULL
        qc_max_loc = NULL
        qc_null_loc = NULL
      }

      temp_field = list(
        name = col_names[i],
        unit = unit,
        info = paste(info, collapse=' '),
        ucd = unique(ucd),
        data_type = data_type,
        array_size = array_size,
        qc = list(
          min = qc_min_loc,
          max = qc_max_loc,
          miss = qc_null_loc
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
      list(
        DOI = 'Valid DOI',
        type = 'DOI type'
      )
    ),
    depends = list(
      list(
        survey = 'Dependent survey',
        dataset = 'Dependent dataset',
        table = 'Dependent table',
        version = 'Dependent table version'
      )
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
    MAML_version = 1.0,
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
