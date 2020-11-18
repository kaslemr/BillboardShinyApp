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
                    "This tab allows you to use regression analysis or random forest to create a predictive model and apply the model on new data to make predictions.",
                    h4("Data"),
                    "This tab allows you view the raw data in tabular form, subset the data, and export the data."
            ),
            # Exploratory Analysis Tab
            tabItem(tabName = "explore",
                    h2("Exploratory Analysis"),
                    fluidRow(
                        box(plotOutput("plot1", height = 250)),
                        
                        box(
                            title = "Controls",
                            sliderInput("slider", "Number of observations:", 1, 100, 50)
                        )
                    )
            ),
            
            # Unsupervised Learning Tab
            tabItem(tabName = "unsupervised",
                    h2("Clustering Analysis")
            ),
            
            # Supervised Learning Tab
            tabItem(tabName = "supervised",
                    h2("Predictive Modeling")
            ),
            
            # Data Tab
            tabItem(tabName = "data",
                    h2("Raw Data")
            )
        )
    )
)
