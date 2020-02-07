

#=== Shiny App Server ===

shinyServer(function(input, output) {

  source(file.path("server", "checkdataset.R"))
  source(file.path("server", "restfullAPI.R"))

  h = hash::hash()
  h2 = hash::hash()

  lis = list(h,h2)


  #==== page #1 ====

  # Render timeseries plot in main panel of page #1
  output$Timeseries <-plotly::renderPlotly({




    couple =  checkdataset(input$years,input$pollutant, lis)
    poll= couple[[1]]
    lis = couple[[2]]
    inp = input$pollutant


    if(input$regression)
    {
      fit <- lm( poll$valore ~ poll$data, data = poll)

      plotly::add_lines(x = ~poll$data, y = fitted(fit), name="regression", plotly::layout(title = paste('Value of ',inp, "per day of ", input$years),
                                                                                           xaxis = list(title = 'Days'),
                                                                                           yaxis = list (title = paste('Value of ',inp)), plotly::plot_ly(x = poll$data, y = poll$valore, name ="values ",type = 'scatter',mode = 'line')))

    }

    else
    {
      plotly::layout(title = paste('Value of ',inp, "per day of ", input$years),
                     xaxis = list(title = 'Days'),
                     yaxis = list (title = paste('Value of ',inp)),plotly::plot_ly(x = poll$data, y = poll$valore, name ="values ",type = 'scatter',mode = 'line'))
    }
  })


  # Render forecast plot in main panel
  output$Forecast<-plotly::renderPlotly({


    couple = checkdataset(input$years,input$pollutant,lis)

    poll= couple[[1]]
    lis = couple[[2]]
    time =xts::xts(poll[,-1],order.by = poll[,1])
    fit = forecast::auto.arima(time)
    TSplotly::TSplot(50,forecast::forecast(fit,input$lag),  Ylab = "Value", Xlab = "Time(Day)",NEWtitle="ARIMA Forecast",title_size =15, ts_original = "Original time series", ts_forecast= "Predicted time series")


  })


  #==== page #2 ====

  #Render number of data detected from each station in the main panel
  output$stations_plot <-plotly::renderPlotly(
    {

      couple =  checkdataset(input$yearstation,NULL,lis)
      df= couple[[1]]
      lis = couple[[2]]
      plotly::layout(title = paste("Number of detected datas from each station - year:",input$yearstation),
                     xaxis = list(title = "Station ID"),
                     yaxis = list(title = "Data detected"), plotly::plot_ly(df,
                                                                            x = df$station_id,
                                                                            y = df$total_detected,
                                                                            type = "bar",color =df$station_id
                     ))

    })


  #Write the station infos in the lateral panel of page
  output$stations_info <- renderText({

    couple=checkdataset(input$yearstation,NULL,lis)
    df= couple[[1]]
    lis = couple[[2]]
    paste("In the year",
          input$yearstation, "there were", length(df$station_id), "active stations.","<br>","The active station were: ")
  })

  #Write which station where active in the lateral panel of page
  output$stations_active <- renderText({

    couple=checkdataset(input$yearstation,NULL,lis)
    df= couple[[1]]
    lis = couple[[2]]
    paste(df$station_id)
  })






})
