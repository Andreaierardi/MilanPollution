#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

pollution <- function()
{
    shinyApp(ui = shinyUI, server = shinyServer)
    shiny::runApp(appDir, display.mode = "normal")

}

installpack <- function()
{
    print("OKKKKK")
    packages  =c("shiny","ggplot2","forecast","xts","ckanr","httr","jsonlite","tidyverse","plotly","TSplotly")
    if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
        install.packages(setdiff(packages, rownames(installed.packages())),repos = "http://cran.us.r-project.org")
    }
    shinyApp(ui = shinyUI, server = shinyServer)

}

scraping <- function(id)
{
    url <- paste0("http://dati.comune.milano.it/api/action/",
                  "datastore_search?", paste("resource_id=", id,"&limit=10000", sep=""))
    page <- GET(url) # API request
    status_code(page) # # Check that the call is successful
    leggo_list <- fromJSON(url)
    leggo <- leggo_list$result$records

    return(leggo)

}

stazioni_clean <- function(file)
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

checkyears  <- function(year, flat)
{

    if(flat)
    {
        if(year=="2019")
        {
            return(flat_ds2019)
        }
        if(year=="2018")
        {
            return(flat_ds2018)
        }
        if(year=="2017")
        {
            return(flat_ds2017)
        }
    }
    if(year=="2019")
    {
        return(ds2019)
    }
    if(year=="2018")
    {
        return(ds2018)
    }
    if(year=="2017")
    {
        return(ds2017)
    }

}


loadlibreries <- function()
{
    require(shiny)
    require(ggplot2)
    require(forecast)
    require(xts)
    require(ckanr)
    require(httr)
    require(jsonlite)
    require(tidyverse)
    require(plotly)
    require(TSplotly)
}


installpack()

loadlibreries()


flat_ds2019= scraping("698a58e6-f276-44e1-92b1-3d2b81a4ad47")
ds2019 = datacleaning(flat_ds2019)

flat_ds2018 = scraping("ea80c691-74bd-4356-94b6-0f446f190c0b")

ds2018 = datacleaning(flat_ds2018)
flat_ds2017= scraping("a032a06e-24c2-4df1-ac83-d001e9ddc577")
ds2017 =datacleaning(flat_ds2017)



test =ds2019
shinyServer(function(input, output) {
    output$stations_info <- renderText({
        paste("In the year",
              input$yearstation, "there were", length(stazioni_clean(checkyears(input$yearstation, TRUE))$station_id), "active stations.","<br>","The active station were: ")
    })

    output$stations_active <- renderText({
        paste(stazioni_clean(checkyears(input$yearstation, TRUE))$station_id)
    })
    output$stations_plot <- renderPlotly(
        {

            flat =  checkyears(input$yearstation, TRUE)
            df =  stazioni_clean(flat)

            plot_ly(df,
                    x = df$station_id,
                    y = df$total_detected,
                    type = "bar",color =df$station_id
            ) %>%
                layout(title = paste("Number of detected datas from each station - year:",input$yearstation),
                       xaxis = list(title = "Station ID"),
                       yaxis = list(title = "Data detected"))

        })

    output$Timeseries <- renderPlotly({




        test = checkyears(input$years, FALSE)
        # Render timeseries plot
        inp = input$pollutant

        poll = subset(test,subset= inquinante==inp)
        poll= poll[,c('data','valore')]
        if(input$regression)
        {
            fit <- lm( poll$valore ~ poll$data, data = poll)

            plot_ly(x = poll$data, y = poll$valore, name ="values ",type = 'scatter',mode = 'line')%>%
                layout(title = paste('Value of ',inp, "per day of ", input$years),
                       xaxis = list(title = 'Days'),
                       yaxis = list (title = paste('Value of ',inp))) %>%
                add_lines(x = ~poll$data, y = fitted(fit), name="regression")

        }

        else
        {
            plot_ly(x = poll$data, y = poll$valore, name ="values ",type = 'scatter',mode = 'line')%>%
                layout(title = paste('Value of ',inp, "per day of ", input$years),
                       xaxis = list(title = 'Days'),
                       yaxis = list (title = paste('Value of ',inp)))
        }
    })

    output$Forecast<- renderPlotly({

        test = checkyears(input$years,FALSE)

        inp = input$pollutant
        poll = subset(test,subset= inquinante==inp)
        poll= poll[,c('data','valore')]
        time = xts(poll[,-1],order.by = poll[,1])
        fit = auto.arima(time)
        TSplot(50,forecast(fit,input$lag),  Ylab = "Value", Xlab = "Time(Day)",NEWtitle="ARIMA Forecast",title_size =15, ts_original = "Original time series", ts_forecast= "Predicted time series")

        # Render a forecast plot


    })


})


