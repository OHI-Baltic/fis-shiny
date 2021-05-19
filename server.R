server <- function(input, output) {
  
  scoresCombined <- reactive({
    req(input$loB)
    req(input$midB)
    req(input$hiB)
    req(input$loF)
    req(input$midF)
    req(input$hiF)
    
    scores <- rbind(
      calc_Bscores(dataset, input$loB, input$midB, input$hiB),
      calc_Fscores(dataset, input$loB, input$midB, input$hiB, input$loF, input$midF, input$hiF)
    )
    scores %>%
      group_by(region_id, stock, year, ffmsy, bbmsy) %>%
      summarize(score = mean(score, na.rm = TRUE), score_type = "Score") %>%
      ungroup() %>% 
      bind_rows(scores)
  })
  
  ## SCORES PLOT ----
  output$scoresPlot <- renderPlot({
    ggplot() +
      geom_line(
        data = filter(scoresCombined(), stock %in% c(input$stock)),
        aes(x = year, y = score, color = stock, size = score_type, linetype = score_type),
        alpha = 0.8
      ) +
      ylim(0, 1) +
      labs(
        x = NULL, y = "Score", 
        title = "Stock Scores (Averages) and two components (F-Scores and B-Scores)",
        color = "Stock", linetype = NULL, size = NULL
      ) +
      guides(color = "none") +
      theme(legend.position = c(0.1, 0.1)) +
      scale_color_manual(values = filter(pal, stock %in% input$stock)$values) +
      scale_linetype_manual(values = c("dotted", "dashed", "solid")) +
      scale_size_manual(values = c(0.5, 0.5, 1)) +
      theme_bw() 
  })
  
  ## BSCORES CURVES PLOT ----
  output$scoreBcurve <- renderPlot({
    ggplot() + 
      geom_line(
        data = filter(scoresCombined(), score_type == "B_score"), 
        aes(bbmsy, score, color = score), 
        size = 2, 
        show.legend = FALSE
      ) + 
      geom_vline(xintercept = input$loB) +
      geom_vline(xintercept = input$midB) +
      ylim(0, 1) +
      labs(x = "B/BMSY", y = "B-Score", title = "Calculating B-Scores") +
      scale_color_viridis() + 
      theme_bw() 
  })
  
  ## FSCORES CURVES PLOT ----
  output$scoreFcurve <- renderPlot({
    ggplot() +
      geom_tile(
        data = calc_Fscores(gridFscore, input$loB, input$midB, input$hiB, input$loF, input$midF, input$hiF), 
        aes(bbmsy, ffmsy, fill = score), 
        alpha = 0.8, 
        show.legend = FALSE
      ) +
      geom_vline(xintercept = input$loB) +
      geom_hline(yintercept = input$loF) +
      geom_hline(yintercept = input$midF) +
      geom_hline(yintercept = input$hiF) +
      labs(x = "B/BMSY", y = "F/FMSY", title = "Calculating F-Scores") + 
      scale_fill_viridis() + 
      theme_bw() + 
      geom_point(
        data = filter(scoresCombined(), score_type == "Score"), 
        aes(bbmsy, ffmsy), 
        shape = 15, size = 3, alpha = 0.01
      )
  })
}