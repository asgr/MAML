library(R6)

#' UCDWords
#'
#' R6 class for managing UCD (Unified Content Descriptor) words.
#' This class loads the valid UCDs from the `inst/extdata/valid_UCD_v1p6.dat` file
#' and provides methods to check primary/secondary status, get descriptions,
#' normalize capitalization, and validate UCD strings.
#'
#' @examples
#' ucd <- UCDWords$new()
#' ucd$is_primary("arith")
#' ucd$is_secondary("arith.diff")
#' ucd$get_description("em.ir.15-30um")
#' ucd$normalize_capitalization("em.ir.15-30um")
#' ucd$check_ucd("arith;em.IR.8-15um")
#'
#' @export
UCDWords <- R6Class("UCDWords",
  public = list(
    primary = NULL,
    secondary = NULL,
    descriptions = NULL,
    capitalization = NULL,
    initialize = function() {
      file_path <- system.file("extdata", "valid_UCD_v1p6.dat", package = "MAML")
      if (file_path == "") {
        stop("valid_UCD_v1p6.dat not found in MAML/extdata/")
      }

      words <- read.table(
        file_path,
        sep = "|",
        comment.char = "#",
        strip.white = TRUE,
        col.names = c("letter", "ucd", "description"),
        stringsAsFactors = FALSE
      )

      self$primary <- tolower(words$ucd[words$letter %in% strsplit("QPEVC", "")[[1]]])
      self$secondary <- tolower(words$ucd[words$letter %in% strsplit("QSEVC", "")[[1]]])

      self$descriptions <- setNames(words$description, tolower(words$ucd))
      self$capitalization <- setNames(words$ucd, tolower(words$ucd))
    },

    #' Check if a UCD is primary.
    #'
    #' @param ucd Character. The UCD string to check.
    #' @return Logical. TRUE if the UCD is primary, FALSE otherwise.
    is_primary = function(ucd) {
      tolower(ucd) %in% self$primary
    },
    #' Check if a UCD is secondary.
    #'
    #' @param ucd Character. The UCD string to check.
    #' @return Logical. TRUE if the UCD is secondary, FALSE otherwise.
    is_secondary = function(ucd) {
      tolower(ucd) %in% self$secondary
    },
    #' Returns the description of the UCD.
    #'
    #' @param ucd Character. The UCD string to check.
    #' @return Character.
    get_description = function(ucd) {
      self$descriptions[[tolower(ucd)]]
    },
    #' Returns the standard capitalization of the UCD.
    #'
    #' @description
        #' Since the standard requires case insensitivity, any capitalization can be passed. This
        #' method returns the standard accepted capitalization.
        #'
    #'
    #' @param ucd Character. The UCD string to check.
    #' @return Character.
    normalize_capitalization = function(ucd) {
      self$capitalization[[tolower(ucd)]]
    },

    #' Check if a UCD string is valid.
    #'
    #' @param ucd Character. The UCD string to check.
    #' @return Logical. TRUE if the UCD is valid, FALSE otherwise.
    check_ucd = function(ucd) {
      parts <- strsplit(tolower(ucd), ";")[[1]]
      valids <- vapply(seq_along(parts), function(i) {
        if (i == 1) {
          self$is_primary(parts[[i]])
        } else {
          self$is_secondary(parts[[i]])
        }
      }, logical(1))
      all(valids)
    }
  )
)
