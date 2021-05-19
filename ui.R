ui <- fluidPage(

  ## Sidebar with a slider inputs
  sidebarLayout(
    sidebarPanel(
      sliderInput("loB", "Lower B", min = 0, max = 5, value = 0.95, step = 0.01),
      sliderInput("midB", "Middle B", min = 1, max = 5, value = 1.3, step = 0.01),
      sliderInput("hiB", "Upper B", min = 2, max = 10, value = 5, step = 0.01),
      sliderInput("loF", "Lower F", min = 0, max = 2, value = 0.5, step = 0.01),
      sliderInput("midF", "Middle F", min = 0, max = 5, value = 1, step = 0.01),
      sliderInput("hiF", "Upper F", min = 1, max = 5, value = 4.5, step = 0.01),
      br(),
      checkboxGroupInput(
        "stock", 
        "View Scores for These Stocks:", 
        choiceNames = list(
          "Cod - Western Baltic", 
          "Cod - Eastern Baltic", 
          "Herring - Gulf of Riga", 
          "Herring - Skagerrak, Kattegat, western Baltic", 
          "Herring, Baltic Proper and Gulf of Finland", 
          "Herring, Gulf of Bothnia"),
        choiceValues = list(
          "cod_SDs22_24", "cod_SDs24_32", "herring_SD_28.1", "herring_SDs20_24", "herring_SDs25_29_32", "herring_SDs30_31"
        )
      )
    ),
    
    ## Main panel with plots
    mainPanel(
      fluidRow(
        splitLayout(
          cellWidths = c("47%", "47%"), 
          plotOutput("scoreBcurve"), 
          plotOutput("scoreFcurve")
        )
      ),
      br(),
      br(), 
      br(),
      fluidRow(
        # splitLayout(
          # cellWidths = c("65%", "35%"),
          plotOutput("scoresPlot")
          # checkboxGroupInput(
          #   "stock", 
          #   "View Scores for These Stocks", 
          #   choiceNames = list(
          #     "Cod - Western Baltic", 
          #     "Cod - Eastern Baltic", 
          #     "Herring - Gulf of Riga", 
          #     "Herring - Skagerrak, Kattegat and western Baltic", 
          #     "Herring, Baltic Proper and Gulf of Finland", 
          #     "Herring, Gulf of Bothnia"),
          #   choiceValues = list(
          #     "cod_SDs22_24", "cod_SDs24_32", "herring_SD_28.1", "herring_SDs20_24", "herring_SDs25_29_32", "herring_SDs30_31"
          #   )
          # )
        # )
      )
    )
  )
)