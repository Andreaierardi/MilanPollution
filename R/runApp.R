#' Milan pollution
#'
#' @description
#' Run Milan pollution Sciny App.\cr\cr
#' The application starts showing the main page in which are presented two plots: the first one is a time series and the second one is a forecast of the timeseries.\cr
#' It is possible to select whether or not to have the linear regression line of the time series and set the number of forecast lag.
#' Then, is possible to select the year of the datas represented by the plots.
#' Datas are taken by the Opendata set of the comune di Milan site using CKAN API.
#' \cr The second part is the stations information. Here, is presented the plot of the datas taken from each ARPA station during the selected year.
#' \cr The last part is the "about" in which is described the project and the author.
#' @return shiny app
#'
#' @examples
#' \dontrun{
#' pollution()
#' }
#' @export
pollution <- function() {
  dir <- system.file("pollution", package = "milanpollution")
  if (dir == "") {
    stop("Could not find pollution. Try re-installing `milanpollution`.", call. = FALSE)
  }

  shiny::runApp(dir, display.mode = "normal")
}

##
