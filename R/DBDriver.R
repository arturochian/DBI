#' @include DBObject.R

##
## DBIDriver class and its methods.
##
## Should we define methods for querying the interface API to find what
## drivers are available on the current R/Splus instance?  Perhaps something 
## reminescent of library()?  DBIDriver() and DBIDriver(help = "RODBC"), say?
## (JDBC driver manager's class idea would be cleaner.)
##

setClass("DBIDriver", representation("DBIObject", "VIRTUAL"))

## The following function "loads" the specific "driver" or package, e.g.,
##     drv <- dbDriver("MySQL")
## Typically, drivers are expected to have a function of the same name
## that does the actual initialization, e.g., Oracle(), MySQL(), ODBC(),
## SQLite(), ....

setGeneric("dbDriver", 
  def = function(drvName, ...) standardGeneric("dbDriver"),
  valueClass = "DBIDriver")

setMethod("dbDriver", "character",
  definition = function(drvName, ...) {
    do.call(as.character(drvName), list(...))
  }
)
setGeneric("dbListConnections", 
  def = function(drv, ...) standardGeneric("dbListConnections")
)
setGeneric("dbUnloadDriver", 
  def = function(drv, ...) standardGeneric("dbUnloadDriver"),
  valueClass = "logical"
)

## return a string indicating the "closest" SQL type for an R/S object
setGeneric("dbDataType",
  def = function(dbObj, obj, ...) standardGeneric("dbDataType"),
  valueClass = "character"
)
## by defualt use the SQL92 data types -- individual drivers may need to
## overload this
setMethod("dbDataType", signature(dbObj="DBIObject", obj="ANY"),
  definition = function(dbObj, obj, ...) dbDataType.default(obj, ...),
  valueClass = "character"
)

"dbDataType.default" <-
  function(obj, ...)
    ## find a suitable SQL data type for the R/S object obj
    ## (this method most likely should be overriden by each driver)
    ## TODO: Lots and lots!! (this is a very rough first draft)
  {
    rs.class <- data.class(obj)
    rs.mode <- storage.mode(obj)
    if(rs.class=="numeric" || rs.class=="integer"){
      sql.type <- if(rs.mode=="integer") "int" else  "double precision"
    }
    else {
      varchar <- function(x, width=0){
        nc <- ifelse(width>0, width, max(nchar(as.character(x))))
        paste("varchar(", nc, ")", sep="")
      }
      sql.type <- switch(rs.class,
        logical = "smallint",
        factor = , character = , ordered = , varchar(obj))
    }
    sql.type
  }