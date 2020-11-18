#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# import libraries
library(shiny)
library(shinydashboard)
library(billboard)
library(tidyverse)
library(DT)
library(randomForest)

# load datasets
data("wiki_hot_100s")
data("spotify_track_data")
spotify_track_data['duration_mins'] <- spotify_track_data['duration_ms'] / 1000 / 60
spotify_track_data['decade'] <- paste0(substr(spotify_track_data$year,1,3),0)
spotify_track_data$yearInt <- as.integer(spotify_track_data$year)


function(input, output, session) {
    
    #getData <- reactive({
    #    newData <- spotify_track_data %>% group_by(year) %>%
    #        summarise(danceabilityMean = mean(danceability, na.rm = TRUE))
    #})
    
    #create year plot in exploratory data
    output$yearPlot <- renderPlot({
        #get filtered data
        var <- input$varsToSelect
        newData <- spotify_track_data %>% group_by(year) %>%
                    summarise(varMean = mean(get(var), na.rm = TRUE))
        
        g <- ggplot(newData, aes(x = year, y = varMean, group = 1)) +
            geom_point() + 
            geom_line() + 
            geom_smooth() +
            theme(axis.text.x = element_text(angle = 30, vjust = 0.25, hjust=0.2)) +
            ylab(var) + 
            ggtitle(paste("Average", var, "by year"))
        g
    })
    
    #create hit songs by artist plot in exploratory data
    output$artistPlot <- renderPlot({
        # You can access the values of the second widget with input$slider2, e.g.
        yearRangeInput <- input$slider1
        
        topArtists <- wiki_hot_100s %>% filter(year >= yearRangeInput[1] & year <= yearRangeInput[2]) %>%
            group_by(artist) %>% tally(sort=TRUE) %>% top_n(20)
        
        g <- ggplot(topArtists, aes(x=reorder(artist,n), y=n)) +
            geom_bar(stat="identity") +
            coord_flip() +
            ylab("Charting Songs") +
            xlab("Artist") +
            ggtitle("Charting Songs by Artist",sub="Displays Top 20")
        g
    })
    
    output$summaryTable <- DT::renderDataTable({
      var <- input$summarizeTableBy
      if (var == "Year"){
        df <- spotify_track_data %>% select(year,
                                            danceability,
                                            energy,
                                            loudness,
                                            speechiness,
                                            acousticness,
                                            instrumentalness,
                                            liveness,
                                            valence,
                                            tempo,
                                            duration_mins,
                                            explicit
        ) %>% group_by(year) %>% summarise_all(mean)
      }
      else if (var == "Artist") {
        df <- spotify_track_data %>% select(artist_name,
                                            danceability,
                                            energy,
                                            loudness,
                                            speechiness,
                                            acousticness,
                                            instrumentalness,
                                            liveness,
                                            valence,
                                            tempo,
                                            duration_mins,
                                            explicit
        ) %>% group_by(artist_name) %>% summarise_all(mean)
      }
      else if (var == "Decade") {
        df <- spotify_track_data %>% select(decade,
                                            danceability,
                                            energy,
                                            loudness,
                                            speechiness,
                                            acousticness,
                                            instrumentalness,
                                            liveness,
                                            valence,
                                            tempo,
                                            duration_mins,
                                            explicit
        ) %>% group_by(decade) %>% summarise_all(mean)
      }

      df
    })
    # Supervised Learning
    data_2010s <- spotify_track_data[spotify_track_data$year >= "2010",]
  
    lm1 <- reactive({lm(reformulate(termlabels = input$varsSupervisedReg, response="year"), data = spotify_track_data)})
    rf1 <- reactive({randomForest(formula = reformulate(termlabels = input$varsSupervisedReg, response="yearInt"), data = spotify_track_data,ntree=as.integer(input$treeSlider))})

    output$supervisedSummary <- renderPrint({
      if(input$supervisedModelSelect == "Linear Regression"){
        fit <- lm1()
        names(fit$coefficients) <- c("Intercept", input$varsSupervisedReg)
        summary(fit)
      }
      else if (input$supervisedModelSelect == "Random Forest"){
          fit <- rf1()
          fit
      }
    })
    
    runPredict <- eventReactive(input$submitParamVals, {
      inputs <- c("danceabilityInput","energyInput","loudnessInput",
                  "speechinessyInput","acousticnessInput","instrumentalnessInput",
                  "livenessInput","valenceInput","tempoInput","durationInput",
                  "explicitInput")
      df <- data.frame()
      for (inputVal in inputs){
        variableName <- substr(inputVal,1,(nchar(inputVal)+1)-6)
        currentVal <- input$inputVal
        if(length(currentVal) > 0){
          df$variableName <- currentVal
        }
      }
      
      if (input$supervisedModelSelect == "Linear Regression"){
        fit <- lm1()
        predict(fit, newdata=df)
      }
      else if (input$supervisedModelSelect == "Random Forest"){
        fit <- rf1()
        predict(fit, newdata=inputVals)
      }
    })
    
    output$prediction <- renderPrint({
      runPredict()
    })
    
    # PCR Analysis
    PCs <- reactive({prcomp(select(spotify_track_data, input$varsPCR) , scale = TRUE)})
    
    output$pcrBiPlot<- renderPlot({
      PCs <- PCs()
      biplot(PCs, xlabs = rep(".", nrow(spotify_track_data)), cex = 1.2)
    })
    
    output$pcrScree<- renderPlot({
      PCs <- PCs()
      screeplot(PCs, type = "lines") #scree plot used for visual
    })
    
    # data tab
    renderRawDataTable <- reactive({
      yearRangeInput <- input$sliderDataTable
      df <- spotify_track_data %>% filter(year >= yearRangeInput[1] & year <= yearRangeInput[2])
    })
    output$rawDataTable <- DT::renderDataTable({renderRawDataTable()})
    
    # Download data as CSV
    # Downloadable csv of selected dataset ----
    output$downloadData <- downloadHandler(
      filename = paste("billboardSongs", ".csv", sep = ""),
      content = function(file) {
        write.csv(renderRawDataTable(), file, row.names = FALSE)
      }
    )
    
    
}