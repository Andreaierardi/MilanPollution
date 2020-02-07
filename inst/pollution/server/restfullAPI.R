#' restfullAPI
#'
#' Get the dataset from the Opendata website of the city of Milan using CRAN API.
#' You can find the id of the dataset at this link \href{https://dati.comune.milano.it/dataset}{Opendata comune di Milano}. \cr
#' At this link, you can find some dataset of common topic. Click on a specified csv dataset to get the id's,
#' then at the bottom of the page you will see "Informazioni supplementari" (Additional information) section.
#' In this table there is the field ID (not packege id or revision id). [PS. CKAN API only supports csv files]\cr\cr
#'
#'
#' @param id character. Identify the ID of the dataset. if \code{NULL} or not a valid ID for a dataset, return an error.
#'
#' @return data.frame
#'
#' @examples
#'
#' #ID's from the "Rilevazione qualita' dell'aria" (Air Quality Detection):\cr
#' #Year 2019: "698a58e6-f276-44e1-92b1-3d2b81a4ad47" \cr
#'    restfullAPI("698a58e6-f276-44e1-92b1-3d2b81a4ad47")
#'
#' #Year 2018: "ea80c691-74bd-4356-94b6-0f446f190c0b" \cr
#'  restfullAPI("ea80c691-74bd-4356-94b6-0f446f190c0b")
#'
#' #Year 2017: "a032a06e-24c2-4df1-ac83-d001e9ddc577"
#'  restfullAPI("a032a06e-24c2-4df1-ac83-d001e9ddc577")
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

