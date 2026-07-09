library(shiny)
library(tidyverse)
library(randomForest)
library(sf)
library(ggplot2)
library(plotly)
library(jpeg)

# Load model and election data
model_rf <- readRDS("model_rf_party.rds")
election_data <- read_csv("election_data_features_filtered.csv")

# Load logos
bjp_logo <- readJPEG("bjp.jpg")
cong_logo <- readJPEG("congress.jpg")

# Load India shapefile (GeoJSON format)
india_states <- st_read("india_states.geojson")

# Standardize state names for join
india_states <- india_states %>%
  mutate(state = str_to_title(st_nm))

# Prepare prediction dataset function
prepare_prediction_data <- function(selected_year) {
  base_data <- election_data %>%
    filter(year == selected_year) %>%
    select(state, constituency, candidate, party, vote_share, vote_margin,
           swing_votes, turnout_impact, incumbent)
  
  set.seed(selected_year)
  base_data <- base_data %>%
    mutate(
      swing_votes = swing_votes + rnorm(n(), 0, 2),
      turnout_impact = turnout_impact + rnorm(n(), 0, 1),
      incumbent = 0
    )
  
  base_data$predicted_party <- predict(model_rf, newdata = base_data)
  
  predicted_data <- base_data %>%
    group_by(state, constituency, predicted_party) %>%
    summarise(avg_vote_share = mean(vote_share, na.rm = TRUE), .groups = "drop") %>%
    group_by(state, constituency) %>%
    slice_max(order_by = avg_vote_share, n = 1, with_ties = FALSE) %>%
    ungroup()
  
  predicted_data <- predicted_data %>%
    mutate(
      final_prediction = recode(predicted_party,
                                "BJP" = "Bharatiya Janata Party",
                                "INC" = "Indian National Congress",
                                "Congress" = "Indian National Congress")
    )
  
  state_winners <- predicted_data %>%
    filter(!is.na(final_prediction), final_prediction %in% c("Bharatiya Janata Party", "Indian National Congress")) %>%
    group_by(state, final_prediction) %>%
    summarise(seats = n(), .groups = "drop") %>%
    group_by(state) %>%
    slice_max(order_by = seats, n = 1, with_ties = FALSE) %>%
    ungroup()
  
  return(state_winners)
}

# Historical seat distribution function
prepare_historical_distribution <- function() {
  election_data %>%
    group_by(year, party) %>%
    summarise(seats = n_distinct(constituency), .groups = "drop") %>%
    mutate(
      party = recode(party,
                     "BJP" = "Bharatiya Janata Party",
                     "INC" = "Indian National Congress",
                     "Congress" = "Indian National Congress")
    ) %>%
    filter(party %in% c("Bharatiya Janata Party", "Indian National Congress"))
}

# UI
ui <- fluidPage(
  titlePanel("🗳️ WhoWins2029 - India Election Predictions"),
  tabsetPanel(
    tabPanel("🗺️ Predicted Map",
             fluidRow(
               column(12,
                      sliderInput("base_year", "Select Base Year:",
                                  min = 2014, max = 2024, value = 2024,
                                  step = 1, sep = ""),
                      plotlyOutput("interactiveMap", height = "700px"),
                      tags$hr(),
                      verbatimTextOutput("state_info")
               )
             )
    ),
    tabPanel("📊 Historical Trends",
             fluidRow(
               column(6,
                      plotOutput("seatTrends", height = "500px")
               ),
               column(6,
                      plotOutput("seatPie", height = "500px")
               )
             )
    )
  ),
  tags$style(HTML("
    body { background-color: #f9f9f9; font-family: 'Segoe UI', sans-serif; }
    h2, h3 { color: #2c3e50; }
    .tab-content { margin-top: 20px; }
  "))
)

# Server
server <- function(input, output, session) {
  
  state_winners <- reactive({
    india_states %>%
      left_join(prepare_prediction_data(input$base_year), by = "state")
  })
  output$interactiveMap <- renderPlotly({
    req(state_winners())
    
    prediction_year <- input$base_year + 5
    
    p <- ggplot(state_winners()) +
      geom_sf(aes(fill = final_prediction, text = paste0(
        "State: ", state, "<br>",
        "Predicted Winner: ", final_prediction
      )), color = "white", size = 0.2) +
      scale_fill_manual(
        values = c(
          "Bharatiya Janata Party" = "#FF9933",
          "Indian National Congress" = "#3399FF"
        ),
        na.value = "grey80",
        name = "Winning Party"
      ) +
      theme_minimal() +
      labs(
        title = paste(prediction_year, "Lok Sabha - Predicted State Winners"),
        subtitle = paste("Random Forest model +", input$base_year, "data"),
        caption = "WhoWins2029 Project"
      ) +
      theme(
        legend.position = "bottom",
        plot.title = element_text(face = "bold", size = 16),
        plot.subtitle = element_text(size = 12)
      )
    
    plotly_obj <- ggplotly(p, tooltip = "text") %>%
      layout(
        legend = list(orientation = "h", x = 0.3, y = -0.1),
        images = list(
          list(
            source = base64enc::dataURI(file = "bjp.jpg", mime = "image/jpeg"),
            x = 0.01, y = 1.01,
            sizex = 0.1, sizey = 0.1,
            xref = "paper", yref = "paper",
            xanchor = "left", yanchor = "top",
            layer = "above"
          ),
          list(
            source = base64enc::dataURI(file = "congress.jpg", mime = "image/jpeg"),
            x = 0.88, y = 1.01,
            sizex = 0.1, sizey = 0.1,
            xref = "paper", yref = "paper",
            xanchor = "left", yanchor = "top",
            layer = "above"
          )
        )
      )
    
    plotly_obj
  })
  

  
  output$seatTrends <- renderPlot({
    historical_data <- prepare_historical_distribution()
    
    ggplot(historical_data, aes(x = year, y = seats, fill = party)) +
      geom_area(position = "stack") +
      scale_fill_manual(
        values = c(
          "Bharatiya Janata Party" = "#FF9933",
          "Indian National Congress" = "#3399FF"
        ),
        name = "Party"
      ) +
      theme_minimal() +
      labs(
        title = "Historical Seat Distribution (2014–2024)",
        x = "Election Year",
        y = "Total Seats Won"
      ) +
      scale_x_continuous(breaks = unique(historical_data$year)) +
      theme(panel.grid.minor = element_blank())
  })
  
  output$seatPie <- renderPlot({
    historical_data <- prepare_historical_distribution() %>%
      filter(year == 2024) %>%
      group_by(party) %>%
      summarise(seats = sum(seats), .groups = "drop")
    
    ggplot(historical_data, aes(x = "", y = seats, fill = party)) +
      geom_col(width = 1) +
      coord_polar(theta = "y") +
      scale_fill_manual(
        values = c(
          "Bharatiya Janata Party" = "#FF9933",
          "Indian National Congress" = "#3399FF"
        ),
        name = "Party"
      ) +
      theme_void() +
      labs(title = "2024 Seat Share (Pie Chart)")
  })
}

# Run the app
shinyApp(ui = ui, server = server)
