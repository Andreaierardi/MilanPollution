#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


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

library(shiny)
loadlibreries()

url = a("Comune di Milano", href="https://dati.comune.milano.it/dataset")

# Define UI for application that draws a histogram
shinyUI(fluidPage( id= "all",
                   titlePanel(h1("Milan Pollution Analisys",id="testa")),
                   tags$style(HTML("html*{font-family: Arial;} #all{background-color:rgb(174, 211, 254,0.2);} p {font-size:16px;font-family:Arial} h1{text-align: center;} .navbar-default .navbar-brand {
                         background-color: #2F4F4F;color: #ffffff;}  .navbar-default .navbar-brand:hover{ background-color: #2F4F4F;color: #ffffff;} .navbar-default{background-color: #8FBC8F;color: #ffffff;border:solid 1px gray;} .navbar > .container-fluid >  ul li.active a:not( :hover ){background-color:#4990c2;color:#ffffff;} .navbar > .container-fluid >  ul li a:hover{background-color:#4990c2;color:#ffffff;} .navbar > .container-fluid >  ul li a{background-color:#8FBC8F;color:#ffffff;} .navbar > .container-fluid >  ul li.active a{background-color:#4990c2;color:#ffffff;} .navbar > .container-fluid >  ul li.active a:hover{background-color:#4990c2;color:#ffffff;} #backg{border:1px solid gray;background-color:#ecf8f2; margin-bottom: 10px;  border-radius: 25px;} .div_container-fluid{background-color:#49c5b6;color:#ffffff} #side{background-color:#f4f5f9;border:1px solid gray;} #testa{ color: #4990c2; font-family: 'Raleway',sans-serif; font-size: 48px; font-weight: 600; line-height: 80px; width:100%;margin: 0 0 10px;text-align:center;background-color:#ffffff;}")),

                   hr(),
                   navbarPage(  "Pollution Milan",
                                tabPanel("Pollution",

                                         sidebarLayout(

                                             sidebarPanel( id="side",
                                                           # Dropdown menu for selecting variable from GE data.
                                                           selectInput("pollutant",
                                                                       label = "Select pollutant type",
                                                                       choices = c("SO2","C6H6","CO_8h","NO2","O3","PM10","PM25","SO2"),
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
))
