library(shiny)
library(tidyverse)
library(shinydashboard)

# Load data
election_data <- read.csv("election_data_features.csv")

# UI
ui <- dashboardPage(
  dashboardHeader(title = "Voter Turnout in India"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    fluidRow(
      box(title = "Year-wise Voter Turnout", width = 12, status = "primary", solidHeader = TRUE,
          plotOutput("turnoutPlot", height = 400))
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Clean and prepare data
  turnout_data <- election_data %>%
    select(year, voter_turnout) %>%
    group_by(year) %>%
    summarise(avg_turnout = mean(voter_turnout, na.rm = TRUE))
  
  # Render plot
  output$turnoutPlot <- renderPlot({
    ggplot(turnout_data, aes(x = year, y = avg_turnout)) +
      geom_line(color = "steelblue", size = 1.2) +
      geom_point(color = "darkred", size = 2) +
      labs(
        title = "Average Voter Turnout by Year in India",
        x = "Year",
        y = "Voter Turnout (%)"
      ) +
      theme_minimal(base_size = 14)
  })
}

# Run the app
shinyApp(ui, server)
