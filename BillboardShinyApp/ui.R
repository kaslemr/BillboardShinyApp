#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(billboard)
library(tidyverse)
library(DT)
library(randomForest)
library(plotly)

# Define UI for application that draws a histogram
dashboardPage(
    dashboardHeader(title = "Billboard Top 100"),
    ## Sidebar content
    dashboardSidebar(
        sidebarMenu(
            menuItem("About", tabName = "home", icon = icon("home")),
            menuItem("Exploratory Analysis", tabName = "explore", icon = icon("chart-bar")),
            menuItem("Clustering Analysis", tabName = "unsupervised", icon = icon("project-diagram")),
            menuItem("Predictive Modeling", tabName = "supervised", icon = icon("chart-line")),
            menuItem("Data", tabName = "data", icon = icon("table"))
        )
    ),
    ## Body content
    dashboardBody(
        tabItems(
            # About Tab
            # An information page that describes the data, the purpose of the app, and how to navigate it
            tabItem(tabName = "home",
                    h2("Home"),
                    h3("About this App"),
                    "Use this app to explore characteristics of popular music across the 20th and 21st centuries, using the year-end Billboard Top 100 chart as a proxy for the most popular songs of each year from 1960 to 2016. The data is sourced from the ",
                    a("billboard libary", href="https://cran.r-project.org/web/packages/billboard/index.html"),
                    ", created by Mikkel Freltoft Krogsholm. The data set includes important information about each song, such as it's artist, title, lyrics, release date, and top 100 ranking, as well as musical features about the song extracted from the Spotify API.",
                    br(),
                    br(),
                    "Beyond home page, the site has four tabs: Exploratory Analysis, Clustering Analysis, Predictive Modeling, and Data. Use menu bar on the left-hand side to navigate between tabs.",
                    h3("App Contents"),
                    h4("Exploratory Analysis"),
                    "This tab allows you to choose different variables to summarize either graphically or with summary tables. This tab will help you get an overview of the data and perform basic analyses.",
                    h4("Clustering Analysis"),
                    "This tab allows you to perform a principal components analysis on a set of variables.",
                    h4("Predictive Modeling"),
                    "This tab allows you to use regression analysis in the form of ",
                    withMathJax(
                      "$$\\hat{Y}_i = \\hat{\\beta}_0 + \\hat{\\beta}_1 X_i + \\hat{\\epsilon}_i$$"
                    ),
                    " or random forest to create a predictive model and apply the model on new data to make predictions.",
                    h4("Data"),
                    "This tab allows you view the raw data in tabular form, subset the data, and export the data."
            ),
            # Exploratory Analysis Tab
            tabItem(tabName = "explore",
                    h2("Exploratory Analysis"),
                    fluidRow(fluidRow(downloadButton("downloadPlot", "Download Plot"))),
                    fluidRow(
                      selectInput("varsToSelect",
                                  "Variables to Summarize",
                                  choices=list("danceability",
                                               "energy",
                                               "loudness",
                                               "speechiness",
                                               "acousticness",
                                               "instrumentalness",
                                               "liveness",
                                               "valence",
                                               "tempo",
                                               "duration_mins",
                                               "explicit"
                                  )
                      ),
                    ),
                    fluidRow(
                      h4("Yearly Trends in Hit Songs", align="center")
                    ),
                    fluidRow(
                      box(plotlyOutput("yearPlot"), width=12)
                    ),
                    # Slider date range
                    fluidRow(
                        sliderInput("slider1", label = strong("Year Range"), min = 1960, 
                                max = 2016, value = c(1960, 2016), sep="")
                    ),
                    fluidRow(
                        h4("Most Popular Artists", align="center")
                    ),
                    fluidRow(
                        box(plotOutput("artistPlot"), width=12)
                    ),
                    fluidRow(
                        radioButtons("summarizeTableBy",
                                     "Summarize Table By",
                                     choices = list("Year",
                                                    "Artist",
                                                    "Decade")
                        )
                    ),
                    fluidRow(
                      DT::dataTableOutput("summaryTable")
                    )
            ),
            
            # Unsupervised Learning Tab
            tabItem(tabName = "unsupervised",
                    h2("Clustering Analysis"),
                    fluidRow(box(checkboxGroupInput("varsPCR", "Variables to include in model:",
                                           c("danceability",
                                             "energy",
                                             "loudness",
                                             "speechiness",
                                             "acousticness",
                                             "instrumentalness",
                                             "liveness",
                                             "valence",
                                             "tempo",
                                             "duration_mins",
                                             "explicit"),
                                           selected=c("danceability","energy"))
                    )),
                    fluidRow(
                      box(plotOutput("pcrBiPlot")),
                      box(plotOutput("pcrScree"))
                    ),
            ),
            
            # Supervised Learning Tab
            tabItem(tabName = "supervised",
                    h2("Predictive Modeling"),
                    fluidRow(
                      box(checkboxGroupInput("varsSupervisedReg", "Variables to include in model:",
                                         c("danceability",
                                           "energy",
                                           "loudness",
                                           "speechiness",
                                           "acousticness",
                                           "instrumentalness",
                                           "liveness",
                                           "valence",
                                           "tempo",
                                           "duration_mins",
                                           "explicit"),
                                         selected="danceability")
                          ),
                      box(radioButtons("supervisedModelSelect",
                                     "Select Model",
                                     choices = list("Linear Regression",
                                                    "Random Forest"
                                                    )
                                     )
                          ),
                    box(conditionalPanel(
                      condition = "input.supervisedModelSelect == 'Random Forest'",
                      sliderInput("treeSlider", label = strong("Number of Trees"), min = 10, 
                                max = 500, value = c(100), sep="")
                      )
                    )
                  ),
                  fluidRow(
                    verbatimTextOutput("supervisedSummary")
                  ),
                  fluidRow(
                    box(
                      textInput("danceabilityInput","Danceability"),
                      textInput("energyInput","Energy"),
                      textInput("loudnessInput","Loudness"),
                      textInput("speechinessyInput","Speechiness"),
                      width = 4
                    ),
                    box(
                      textInput("acousticnessInput","Acousticness"),
                      textInput("instrumentalnessInput","Instrumentalness"),
                      textInput("livenessInput","Liveness"),
                      textInput("valenceInput","Valence"),
                      width = 4
                    ),
                    box(
                      textInput("tempoInput","Tempo"),
                      textInput("durationInput","Duration (Minutes)"),
                      textInput("explicitInput","Explicit"),
                      actionButton("submitParamVals","Submit and Run"),
                      width = 4
                    )
                  ),
                  fluidRow(
                    verbatimTextOutput("prediction")
                  )
            ),
            
            # Data Tab
            tabItem(tabName = "data",
                    h2("Raw Data"),
                    fluidRow(
                      sliderInput("sliderDataTable", label = strong("Year Range"), min = 1960, 
                                  max = 2016, value = c(1960, 2016), sep="")
                    ),
                    fluidRow(downloadButton("downloadData", "Download")),
                    fluidRow(
                      box(DT::dataTableOutput("rawDataTable")
                      )
                    )
            )
        )
    )
)
