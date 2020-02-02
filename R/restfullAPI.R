#' restfullAPI
#'
#' Get the dataset from the Opendata website of the city of Milan using CRAN API.
#' @param id character. Identify the ID of the dataset. if \code{NULL} or not a valid ID for a dataset, return an error.
#'
#' @return data.frame
#'
#' @examples
#' restfullAPI(id)
#'
#' @export
#'
restfullAPI <- function(id = NULL)
{
  if (is.null(id) ) {
    stop("Please, insert a valid ID for the dataset", call. = FALSE)
  }

  else{
    url <- paste0("http://dati.comune.milano.it/api/action/",
                  "datastore_search?", paste("resource_id=", id,"&limit=10000", sep=""))
    page <- httr::GET(url) # API request

    check = httr::status_code(page)
    # Check that the call is successful
    if(check!=200)
      stop("The OpenData website does not have a dataset with this ID. \nCheck more databases at the website: http://dati.comune.milano.it/dataset (ONLY those csv file that support CKAN API) ", call. = FALSE)

    leggo_list <- jsonlite::fromJSON(url)
    leggo <- leggo_list$result$records

    message(paste0("Dataset id: ",id," downloaded with success"))
    return(leggo)


  }


}

