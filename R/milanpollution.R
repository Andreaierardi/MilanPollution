#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#Make a README
#https://www.makeareadme.com/



# Run the application
pollution <- function()
{


  installpack <- function()
  {
    packages  =c("shiny","ggplot2","forecast","xts","ckanr","httr","jsonlite","tidyverse","plotly","TSplotly")
    if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
      install.packages(setdiff(packages, rownames(installed.packages())),repos = "http://cran.us.r-project.org")
    }
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

  url = a("Comune di Milano", href="https://dati.comune.milano.it/dataset")

  flat_ds2019= scraping("698a58e6-f276-44e1-92b1-3d2b81a4ad47")
  ds2019 = datacleaning(flat_ds2019)
  flat_ds2018 = scraping("ea80c691-74bd-4356-94b6-0f446f190c0b")

  ds2018 = datacleaning(flat_ds2018)
  flat_ds2017= scraping("a032a06e-24c2-4df1-ac83-d001e9ddc577")
  ds2017 =datacleaning(flat_ds2017)


  test =ds2019

  # Define UI for application
  ui <- fluidPage( id= "all",
    titlePanel(h1("Milan Pollution Analisys",id="testa")),
                  tags$style(HTML("html*{font-family: Arial;} #all{background-color:rgb(174, 211, 254,0.2);} p {font-size:16px;font-family:Arial} h1{text-align: center;} .navbar-default .navbar-brand {
                         background-color: #2F4F4F;color: #ffffff;}  .navbar-default .navbar-brand:hover{ background-color: #2F4F4F;color: #ffffff;} .navbar-default{background-color: #8FBC8F;color: #ffffff;} .navbar > .container-fluid >  ul li.active a:not( :hover ){background-color:#4990c2;color:#ffffff;} .navbar > .container-fluid >  ul li a:hover{background-color:#4990c2;color:#ffffff;} .navbar > .container-fluid >  ul li a{background-color:#8FBC8F;color:#ffffff;} .navbar > .container-fluid >  ul li.active a{background-color:#4990c2;color:#ffffff;} .navbar > .container-fluid >  ul li.active a:hover{background-color:#4990c2;color:#ffffff;} #backg{border:1px solid gray;background-color:#ecf8f2; margin-bottom: 10px;  border-radius: 25px;} .div_container-fluid{background-color:#49c5b6;color:#ffffff} #side{background-color:#f4f5f9;border:1px solid gray;} #testa{ color: #4990c2; font-family: 'Raleway',sans-serif; font-size: 48px; font-weight: 600; line-height: 80px; width:100%;margin: 0 0 10px;text-align:center;background-color:#ffffff;}")),

                  hr(),
                  navbarPage(  "Pollution Milan",
                              tabPanel("Pollution",

                                       sidebarLayout(

                                         sidebarPanel( id="side",
                                                       # Dropdown menu for selecting variable from GE data.
                                                       selectInput("pollutant",
                                                                   label = "Select pollutant type",
                                                                   choices = unique(test$inquinante),
                                                                   selected = "PM10"),
                                                       # Default selection
                                                       sliderInput("lag",
                                                                   "Forecasting lags:",
                                                                   min = 1,  max = 50, value = 10),


                                                       br(),
                                                       checkboxInput("regression", "Show Regression line", TRUE),
                                                       hr(),
                                                       helpText("Data from openData",url),
                                                       hr(),
                                                       br(),
                                                       selectInput("years",
                                                                   label = "Select the year",
                                                                   choices = c("2019","2018","2017"),
                                                                   selected = "2019"),


                                         ),

                                         mainPanel(id="backg",

                                                   h1("Plot results"),
                                                   hr(),
                                                   plotlyOutput('Timeseries'),
                                                   br(),
                                                   hr(),
                                                   plotlyOutput("Forecast"),
                                                   br(),

                                         )


                                       ) ),

                              tabPanel(id="side","Stations",
                                       sidebarLayout(
                                         sidebarPanel( id="side",

                                                       h1("Number of active stations"),
                                                       hr(),

                                                       htmlOutput("stations_info"),
                                                       htmlOutput("stations_active"),

                                                       hr(),
                                                       selectInput("yearstation",
                                                                   label = "Select the year",
                                                                   choices = c("2019","2018","2017"),
                                                                   selected = "2019"),
                                                       br(),


                                                       helpText("Data from openData",url),


                                         ),

                                         mainPanel(id="backg",
                                                   h1("Plot results"),
                                                   hr(),
                                                   plotlyOutput("stations_plot"),
                                                   br(),
                                         ))

                              ),
                              tabPanel("About", id = "side",

                                       sidebarLayout(
                                         sidebarPanel( id="side",

                                                       h1("Author"),
                                                       hr(),
                                                       h2("Andrea Ierardi"),
                                                       tags$img(src="https://avatars0.githubusercontent.com/u/36515398?s=460&v=4", width = "150px", height = "150px"),
                                                       hr(),
                                                       h2("Studies"),

                                                       p("MSc. Data Science and Economics student - Università degli studi di Milano."),
                                                       p("Graduated in Computer Science - Università del Piemonte orientale(UPO)"),
                                                       hr(),

                                                       h2("LINKS"),
                                                       a("LinkedIn", href="https://www.linkedin.com/in/andreaierardi/"),
                                                       br(),
                                                       a("Github",href="https://github.com/Andreaierardi")


                                         ),



                                         mainPanel(id="backg",
                                                   h1("About"),
                                                   hr(),
                                                   p("The aim of this project is the analysis of the data taken from the site of the Comune di Milano using CKAN Data Application programming interface(API)."),
                                                   h2("Main page: Pollution"),
                                                   p("In the main page are presented two plots: the time series of the datas and the related forecast."),

                                                   tags$li("The first plot represents the time series of the data deteceted by every station day by day. It is possible to check the Checkbox to enable the visualization of the linear regression line."),
                                                   tags$li("The second plot represents the forecast of the time series. It is possible to set a different lag for the forecast using the slidebar."),
                                                   p("Then is possible to select the year of the dataset in interest using a selector."),

                                                   br(),
                                                   h2("Second page: Stations"),
                                                   p("In this page is possible to see the barplot representing the detected data from each station in the selected year."),
                                                   br(),
                                                   h2("Third page: About"),
                                                   p("This section describes the aim of the project."),
                                                   br()

                                         )
                                       )
                              )
                  )
  )

  # Define server logic required to draw plots
  server <- function(input, output) {

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


  }



  shinyApp(ui = ui, server = server )

}

#to start the application
#pollution()

