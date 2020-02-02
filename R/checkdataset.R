#' Checkdataset
#'
#' Check whether and which datasetis already loaded, download and visualise it.
#' If the dataset is loaded, then get that from an \code{hash}, if not loaded then call \code{\link{restfullAPI}} and upload the \code{hash} If pollutant is \code{NULL} then the function will get the time series dataset else the function will get the data detected from each station. It return a list contains the dataset cleaned and requested and a list containing the hash of the dataset already download to keep it in memory. PS. This only works with "Rilevazione qualità aria" dataset of openData website!
#'
#' @param year character. The year of the dataset to check
#' @param pollutant character. The name of the pollutant to check. If \code{NULL} (the default) means we are checking the dataset for the stations else we are checking for time series.
#' @param lis list. The list contains on the first slot the dataset requested (using \code{pollutant} parameter) and on the second slot uploaded the hash to maintain the dataset in memory.
#'
#' @return list
#' @export
#' @examples
#' \dontrun{
#' checkdataset(year, pollutant, lis)
#' }
checkdataset <- function(year, pollutant = NULL, lis =NULL)
{

  if(is.null(year))
    stop("Year parameter empty",call.=FALSE)

  #check if the year is already loaded
  lis  = checkYears(year,lis)
  h = lis[[1]]
  h2= lis[[2]]

  #If pollutant is not NULL, then are requested dataset for timeseries(page 1)
  if(!is.null(pollutant))
  {

    test = h[[year]]
    test = subset(test,subset= test$inquinante==pollutant)
    test= test[,c('data','valore')]
    lis = list(h,h2)
    return(list(test,lis))

  }

  #else pollutant is NULL, then are requested dataset for stations info(page 2)
  else
  {
    df = h2[[year]]
    lis = list(h,h2)
    return(list(df,lis))
  }

}


#' Check years Milan Pollution
#'
#' Check if dataset of years 2017, 2018 or 2019 is already loaded
#' @param year character. The year of the dataset to check
#' @param lis list. List that contains the hash of saved dataset
#'
#'
#' @return list
#'
#' @examples
#' \dontrun{
#' checkYears(year, lis)
#' }
checkYears <- function(year,lis)
{

  if(is.null(lis))
    lis = list(hash::hash(),hash::hash())

  tmph = lis[[1]]
  tmph2 = lis[[2]]

  if(is.null(tmph[[year]])| is.null(tmph2[[year]]))
  {

    id <- switch(year,"2019" = "698a58e6-f276-44e1-92b1-3d2b81a4ad47" ,"2018"= "ea80c691-74bd-4356-94b6-0f446f190c0b","2017" =  "a032a06e-24c2-4df1-ac83-d001e9ddc577")
    if(is.null(id))
      stop("Could not find the year ID of the dataset. Insert an year between 2017, 2018 or 2019", call. = FALSE)

    df = restfullAPI(id)
    test = datacleaning(df)
    tmph[[year]] = test
    tmph2[[year]]= station_clean(df)

  }
  return(lis)
}


#' Clean dataset TS
#'
#' Clean the dataset for time series. It will delete the station_id, remove NA and convert the classes of the objects.
#' Then, aggregate the value detected in the same day using a mean function
#'
#' @param leggo data.frame. Dataframe to clean
#'
#' @return data.frame. Dataframe cleaned
#'
#'
#' @examples
#' \dontrun{
#' datacleaning(leggo)
#' }
datacleaning <- function(leggo)
{
  Data = leggo
  Data$stazione_id=NULL
  Data$`_id`=NULL
  Data$valore = as.double(Data$valore)
  Data$inquinante = as.factor(Data$inquinante)
  Data = Data[complete.cases(Data),]
  Data$data = as.Date(Data$data)
  test = aggregate(valore~ data+inquinante, Data , mean)

  return (test)
}


#' Clean dataset Stations
#'
#' Clean the dataset for station informations. Convert the classes of the object, remove NA and create a new dataframe with the station informations.
#' @param file data.frame. Dataframe to clean
#'
#' @return data.frame. Dataframe cleaned
#'
#'
#' @examples
#' \dontrun{
#' station_clean(file)
#' }
station_clean <- function(file)
{
  file$valore = as.double(file$valore)
  file$inquinante = as.factor(file$inquinante)
  file$stazione_id = factor(file$stazione_id)
  file = file[complete.cases(file),]


  i = sort(unique(file$stazione_id))
  df = data.frame()
  for(j in i)
  {
    missing = file$stazione_id == j
    lis = list(j,length(file$stazione_id[missing]))
    df = rbind(df,lis,stringsAsFactors=FALSE)
  }
  colnames(df)= c("station_id","total_detected")

  return(df)


}

