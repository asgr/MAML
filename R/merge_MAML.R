merge_MAML = function(MAML_primary, MAML_secondary, prefer='primary', output='MAML'){
  # if(length(MAML_primary) != length(MAML_secondary)) {
  #   stop("The lists do not have the same length.")
  # }
  #
  # if(any(names(MAML_primary) != names(MAML_secondary))){
  #   stop("The lists do not have the same top-level contents.")
  # }
  #
  # if(any(names(MAML_primary$fields) != names(MAML_secondary$fields))){
  #   stop("The lists do not have the same fields contents.")
  # }
  i = NULL

  if(inherits(MAML_primary, 'MAML') | (is.character(MAML_primary) & length(MAML_primary) == 1L)){
    MAML_primary = MAML_to_list(MAML_primary)
  }

  if(inherits(MAML_secondary, 'MAML') | (is.character(MAML_secondary) & length(MAML_secondary) == 1L)){
    MAML_secondary = MAML_to_list(MAML_secondary)
  }

  names_primary = names(MAML_primary)
  names_fields_primary = foreach(i = MAML_primary[['fields']], .combine='c')%do%{i[['name']]}
  names_secondary = names(MAML_secondary)
  names_fields_secondary = foreach(i = MAML_secondary[['fields']], .combine='c')%do%{i[['name']]}

  for(i in names_primary){
    if(length(MAML_primary[[i]]) <= 1){
      if((is.null(MAML_primary[[i]]) | prefer=='secondary') & !is.null(MAML_secondary[[i]])){
        MAML_primary[[i]] = MAML_secondary[[i]]
      }
    }else{
      for(j in seq_along(MAML_primary[[i]])){
        if(i == 'fields'){
          #this needs to be a number, because fields sublists are not named
          j_sec = which(names_fields_secondary == names_fields_primary[j])
        }else{
          j_sec = j
        }
        if(length(MAML_primary[[i]][[j]]) <= 1){
          if((is.null(MAML_primary[[i]][[j]]) | prefer=='secondary') & !is.null(MAML_secondary[[i]][[j_sec]])){
            MAML_primary[[i]][[j]] = MAML_secondary[[i]][[j_sec]]
          }
        }else{
          for(k in seq_along(MAML_primary[[i]][[j]])){
            if(length(MAML_primary[[i]][[j]][[k]]) <= 1){
              if((is.null(MAML_primary[[i]][[j]][[k]]) | prefer=='secondary') & !is.null(MAML_secondary[[i]][[j_sec]][[k]])) {
                MAML_primary[[i]][[j]][[k]] = MAML_secondary[[i]][[j_sec]][[k]]
              }
            }else{
              for(m in seq_along(MAML_primary[[i]][[j]][[k]])){
                if(length(MAML_primary[[i]][[j]][[k]][[m]]) <= 1){
                  if((is.null(MAML_primary[[i]][[j]][[k]][[m]]) | prefer=='secondary') & !is.null(MAML_secondary[[i]][[j_sec]][[k]][[m]])) {
                    MAML_primary[[i]][[j]][[k]][[m]] = MAML_secondary[[i]][[j_sec]][[k]][[m]]
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  if(tolower(output) == 'maml'){
    return(list_to_MAML(MAML_primary))
  }else if(tolower(output) == 'list'){
    return(MAML_primary)
  }else{
    stop('Output type must be MAML or list!')
  }
}
