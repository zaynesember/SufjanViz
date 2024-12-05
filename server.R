# Server

server <- function(input, output, session) {
  
  # Dynamic updates to UI
  
  observe({
    lyrics <- (df_trackviz %>% filter(name==input$wc_song) %>% pull(lyrics))[[1]]
    
    lyrics <- gsub("\r?\n", "<br/>", lyrics)  # Handle \r\n and \n
    lyrics <- gsub("\r", "<br/>", lyrics)  # Handle any remaining \r
    
    output$lyricColumn <- renderUI({
      tagList(
        h4(input$wc_song),
        p(HTML(lyrics), style = "font-size:75%;"),
        hr()
      )
    })
  })
  
  
  observeEvent(input$by_albums, {
    if(!input$by_albums){
      updateCheckboxInput(session, "album_images", value=F)
    }
  })
  
  subsetted_wordcloud <- reactive({
    req(input$wc_album)
    df_trackviz_wordcloud %>% filter(Album==input$wc_album,
                                     text != "")
  })
  
  
  observe({
    req(input$wc_album)
    updateSelectInput(session, "wc_song",
                      label = "Song",
                      choices = subsetted_wordcloud() %>% pull(name),
                      selected="Chicago")
    
  })
  
  subsetted_controls <- reactive({
    req(input$xvar_track)
    df_num %>% select(-!!input$xvar_track, -`Album release date`)
  })
  
  observe({
    updateCheckboxGroupInput(session, "controls_select", "", choices=names(subsetted_controls()))
  })
  
  # TRACKS
  
  # Data for the Tracks panel
  subsetted <- reactive({
    req(input$Album)
    if(input$exclude_instrumentals){
      df_trackviz %>% filter(Album %in% input$Album, text != "")
    }
    else{
      df_trackviz %>% filter(Album %in% input$Album)
    }
  })
  
  subsetted_table <- reactive({
    if(input$exclude_instrumentals){
      df_sub <- df_trackviz %>% filter(Album %in% input$Album, text != "") %>%
        select(input$xvar, input$yvar)
    }
    else{
      df_sub <- df_trackviz %>% select(input$xvar, input$yvar)
    }
    
    if("Album release date" %in% names(df_sub)) df_sub <- df_sub %>% select(-"Album release date")
    
    df_sub %>%
      pivot_longer(everything(), names_to="variable", values_to="value") %>%
      group_by(variable) %>%
      summarize(Min=round(min(value, na.rm=T), 2),
                Q1=round(quantile(value, probs=0.25, na.rm=T), 2),
                Mean=round(mean(value, na.rm=T), 2),
                Median=round(median(value, na.rm=T), 2),
                Q3=round(quantile(value, probs=0.75, na.rm=T), 2),
                Max=round(max(value, na.rm=T), 2),
                `Std. dev.`=round(sd(value, na.rm=T))) %>%
      pivot_longer(-variable, names_to="Statistic") %>%
      pivot_wider(names_from=variable)
  })
  
  # Scatter elements
  output$scatter <- renderPlot({
    p <- ggplot(subsetted(), aes(!!input$xvar, !!input$yvar)) +
      theme_bw() +
      list(
        theme(legend.position = "bottom",
              legend.text=element_text(size=8)),
        if(input$by_albums) aes(color = Album),
        if(input$by_albums) scale_color_manual(values=album_colors),
        geom_point(),
        if(input$album_images) geom_image(aes(image=album_img_path, color=NULL), size=input$slider),
        if(input$album_images & !input$show_margins & !input$smooth) theme(legend.position="none"),
        if(input$smooth) geom_smooth(method=input$smooth_type, se=F),
        labs(color=""),
        if(input$xvar=="Track position in album (%)*" |
           input$yvar=="Track position in album (%)*") labs(caption="* Calculated as % of the way through the album's duration the track starts at.")
      )
    
    if (input$show_margins) {
      p <- ggExtra::ggMarginal(p, type = tolower(input$margin_type), margins = "both",
                               size = 8, groupColour = input$by_albums, groupFill = input$by_albums)
    }
    
    p
  }, res = 100)
  
  output$table <- DT::renderDT({
    DT::datatable(subsetted_table(),
                  rownames=F,
                  options = list(dom = 't'))
  })
  
  
  # Reactive model fitting function
  fit <- reactive({
    req(input$yvar, input$xvar)  # Ensure both inputs are selected
    
    # Prevent fitting a model if x and y variables are identical
    if (input$yvar == input$xvar) {
      print("Warning: Y and X variables are identical.")
      return(NULL)  # Returning NULL to handle identical variables gracefully
    }
    
    # Try fitting the model; handle errors gracefully
    tryCatch({
      lm(subsetted()[[input$yvar]] ~ subsetted()[[input$xvar]], data = subsetted())
    }, error = function(e) {
      print(paste("Error in model fitting:", e$message))
      NULL
    })
  })
  
  # Generate the regression table output
  output$regression_table <- renderDT({
    req(fit())  # Ensure the model fit is valid
    
    # If model is NULL (e.g., identical x and y), show message
    if (is.null(fit())) {
      return(datatable(data.frame(Message = "Regression model could not be fit. Check your variable selections.")))
    }
    
    title <- paste("Effect of <strong>", input$xvar, 
                   "</strong> on <strong>", input$yvar, 
                   "</strong>")
    
    # Tidy the model output and select only the necessary columns
    tidy_fit <- broom::tidy(fit(), conf.int = TRUE) %>%
      select(term, estimate, std.error, conf.low, conf.high, p.value) %>%
      mutate(estimate=round(estimate, 3),
             std.error=round(std.error, 3),
             conf.low=round(conf.low, 3),
             conf.high=round(conf.high, 3),
             p.value=round(p.value, 3))
    
    
    tidy_fit$term <- c("Intercept", as.character(input$xvar))
    
    
    # Render the table with customized column names
    datatable(
      tidy_fit,
      colnames = c("Term", "Estimate", "Std. Error", "Lower 95% CI", "Upper 95% CI", "p-value"),
      class = 'compact',  # Makes the table more compact
      options = list(
        dom = 't',         # Display only the table without any controls
        pageLength = nrow(tidy_fit),  # Show all rows
        autoWidth = TRUE
      ),
      rownames=F,
      caption=HTML(title)
    )
  })
  
  
  # ALBUMS
  
  subsetted_bar <- reactive({
    req(input$Album_bar)
    df_trackviz %>% filter(Album %in% input$Album_bar)
  })
  
  output$bar <- renderPlot({
    
    strip_text_size <- {
      if(length(input$Album_bar)==11) 6
      else if(length(input$Album_bar %in% 6:7)) 6.5
      else if(length(input$Album_bar %in% 4:6)) 7
      else if(length(input$Album_bar %in% 0:4)) 8
    }
    
    p2 <- ggplot(subsetted_bar(), aes(x=track_number, y=!!input$barvar,
                                      fill=factor(`Album`))) +
      theme_bw() +
      list(
        geom_bar(stat="identity",position="dodge", width=.55),
        scale_x_discrete(expand = c(0,0)),
        scale_fill_manual(values=album_colors),
        
        theme(
          axis.title.x=element_blank(),
          axis.text.y = element_text(size=7),
          axis.title.y = element_text(angle=90, size=9,
                                      margin=margin(0,5,0,0, unit="pt")),
          legend.position="none",
          strip.background = element_blank(),
          strip.text.x=element_text(size=strip_text_size, vjust=1, margin=margin(-0.1,0,0,0)),
          panel.spacing = unit(.05, "lines"),
          panel.border = element_blank(),
          plot.margin = margin(0,.05,.05,0),
          panel.grid.major = element_line(color="seashell3",
                                          linewidth=.25, linetype="dotted")
        )
      ) +
      facet_wrap(~Album, nrow=1, scales="free_x", strip.position="bottom",
                 labeller=label_wrap_gen(10))
    
    p2
  }, res = 100)
  
  output$table_bar <- DT::renderDT({
    DT::datatable(subsetted_bar() %>% group_by(Album) %>%
                    summarize(Mean=round(mean(!!input$barvar, na.rm=T), 2),
                              Median=round(median(!!input$barvar, na.rm=T), 2),
                              `Std Dev`=round(sd(!!input$barvar, na.rm=T), 2),
                              `Min`=round(min(!!input$barvar, na.rm=T), 2),
                              `Max`=round(max(!!input$barvar, na.rm=T), 2)) %>%
                    rename_with(.fn=~paste(., input$barvar),
                                .cols=c(Mean, Median, `Std Dev`, Min, Max)),
                  rownames=F,
                  options = list(dom = 't'))
  })
  
  # LYRICS
  
  # Define a reactive expression for the document term matrix
  terms <- reactive({
    # Change when the song is changed...
    req(input$wc_song)
    # ...but not for anything else
    #isolate({
      withProgress({
        setProgress(message = "Processing corpus...")
        getTermMatrix(input$wc_song)
      })
    #})
  })
  
  # Only working for first song selected by default
  # observeEvent(input$wc_song, {
  #   print(max(terms()))
  #   updateSliderInput(session=session, inputId="freq", 
  #                     min=min(terms()), max=max(terms()), value=min(terms()))
  # })
  # 
  
  output$wordcloud <- renderWordcloud2({
    v <- data.frame(words=names(terms()), freq=terms()) #%>%
      #filter(ifelse(max(freq, na.rm=T) < input$freq, freq >= input$freq, freq>=0))
    
    wordcloud2(v, color=unname(album_colors))
  })
  
  output$table_wc <- DT::renderDT({
    DT::datatable(subsetted_wordcloud() %>% filter(name==input$wc_song) %>%
                    select(-name, -id, -Album, -text) %>%
                    mutate(`Tempo (bpm)`=round(`Tempo (bpm)`),
                           `Words per minute`=round(`Words per minute`),
                           `Duration (s)`=round(`Duration (s)`)) %>%
                    pivot_longer(everything(), names_to="Variable", values_to="Value") %>%
                    arrange(Variable),
                  rownames=F,
                  options = list(dom = 't'))
  })
  
  # STREAMING
  
  subsetted_streams <- reactive({
    req(input$Album2)
    if(input$exclude_instrumentals2){
      df_streams %>% filter(Album %in% input$Album2, text != "")
    }
    else{
      df_streams %>% filter(Album %in% input$Album2)
    }
  })
  
  subsetted_table_streams <- reactive({
    if(input$exclude_instrumentals2){
      df_sub <- df_streams %>% filter(Album %in% input$Album2, text != "") %>%
        select(input$xvar_track, input$yvar_stream)
    }
    else{
      df_sub <- df_streams %>% select(input$xvar_track, input$yvar_stream) 
    }
    
    if("Album release date" %in% names(df_sub)) df_sub <- df_sub %>% select(-"Album release date")
    
    df_sub %>%
      pivot_longer(everything(), names_to="variable", values_to="value") %>%
      group_by(variable) %>%
      summarize(Min=round(min(value, na.rm=T), 2),
                Q1=round(quantile(value, probs=0.25, na.rm=T), 2),
                Mean=round(mean(value, na.rm=T), 2),
                Median=round(median(value, na.rm=T), 2),
                Q3=round(quantile(value, probs=0.75, na.rm=T), 2),
                Max=round(max(value, na.rm=T), 2),
                `Std. dev.`=round(sd(value, na.rm=T))) %>%
      pivot_longer(-variable, names_to="Statistic") %>%
      pivot_wider(names_from=variable)
  })
  
  # Reactive model fitting function
  fit_streams <- reactive({
    req(input$yvar_stream, input$xvar_track)  # Ensure both inputs are selected
    
    # Prevent fitting a model if x and y variables are identical
    if (input$yvar_stream == input$xvar_track) {
      print("Warning: Y and X variables are identical.")
      return(NULL)  # Returning NULL to handle identical variables gracefully
    }
    
    # Get the y and x variable names as characters
    y_var <- input$yvar_stream
    x_var <- input$xvar_track
    
    # Start building the formula string
    formula_string <- paste0("`", y_var, "` ~ `", x_var, "`")
    
    # Add control variables if any are selected
    if (!is.null(input$controls_select) && length(input$controls_select) > 0) {
      # Surround each control variable with backticks
      control_terms <- paste0("`", input$controls_select, "`", collapse = " + ")
      formula_string <- paste(formula_string, "+", control_terms)
    }
    
    # Convert the formula string to a formula object
    formula <- as.formula(formula_string)
    
    # Try fitting the model; handle errors gracefully
    tryCatch({
      #lm(subsetted_streams()[[input$yvar_stream]] ~ subsetted_streams()[[input$xvar_track]], data = subsetted_streams())
      lm(formula_string, data=subsetted_streams())
    }, error = function(e) {
      print(paste("Error in model fitting:", e$message))
      NULL
    })
  })
  
  output$table_streams <- DT::renderDT({
    DT::datatable(subsetted_table_streams(),
                  rownames=F,
                  options = list(dom = 't'))
  })
  
  # streaming scatter
  output$scatter_streams <- renderPlot({
    
    p <- ggplot(subsetted_streams(), aes(!!input$xvar_track, !!input$yvar_stream)) +
      theme_bw() +
      list(
        theme(legend.position = "bottom",
              legend.text=element_text(size=8)),
        if(input$by_albums2) aes(color = Album),
        if(input$by_albums2) scale_color_manual(values=album_colors),
        geom_point(),
        if(input$album_images2) geom_image(aes(image=album_img_path, color=NULL), size=input$slider2),
        if(input$album_images2 & !input$show_margins2 & !input$smooth2) theme(legend.position="none"),
        #if(input$smooth2) geom_smooth(method=input$smooth_type2, se=F),
        labs(color=""),
        if(input$xvar_track=="Track position in album (%)*") labs(caption="* Calculated as % of the way through the album's duration the track starts at.")
      )
    
    # Add line of best fit and confidence intervals accounting for control variables
    model <- fit_streams()
    if (!is.null(model)) {
      # Generate a new dataset for predictions
      x_range <- seq(min(subsetted_streams()[[input$xvar_track]], na.rm = TRUE),
                     max(subsetted_streams()[[input$xvar_track]], na.rm = TRUE),
                     length.out = 100)  # Generate 100 evenly spaced points for x
      
      y_range <- seq(min(subsetted_streams()[[input$yvar_stream]], na.rm = TRUE),
                     max(subsetted_streams()[[input$yvar_stream]], na.rm = TRUE),
                     length.out = 100)  # Generate 100 evenly spaced points for y
      
      control_means <- subsetted_streams() %>%
        dplyr::summarize(across(all_of(input$controls_select), mean, na.rm = TRUE))  # Calculate means for control vars
      
      
      # Create prediction data frame
      prediction_data <- data.frame(xvar = x_range, yvar=y_range) %>% 
        dplyr::bind_cols(control_means)
      
        
      # Rename the xvar column to the name of the input variable
      colnames(prediction_data)[1] <- as.character(input$xvar_track)
      colnames(prediction_data)[2] <- as.character(input$yvar_stream)
      
      # Add predictions and confidence intervals
      prediction <- predict(model, newdata = prediction_data, interval = "confidence", level = 0.95)
      
      prediction_data <- prediction_data %>%
        mutate(fit = prediction[, "fit"],
               lwr = prediction[, "lwr"],
               upr = prediction[, "upr"])
      
      # Add the fitted line to the plot
      p <- p +
        geom_line(data = prediction_data, aes_string(x = input$xvar_track, y = "fit"),
                  color = "red", size = 1)
      
      # Add confidence interval ribbon if stream_margins is TRUE
      if (T) {
        p <- p +
          geom_ribbon(data = prediction_data,
                      #aes(x = !!input$xvar_track, ymin = lwr, ymax = upr),
                      aes(
                        x = .data[[input$xvar_track]],  # Use tidy evaluation for dynamic x
                        y = .data[[input$yvar_stream]],
                        ymin = lwr,
                        ymax = upr
                      ),
                      fill = "red", alpha = 0.2)
      }
    }
    
    p
  }, res = 100)
  
  
  # Generate the regression table output
  output$regression_table_streams <- renderDT({
    req(fit_streams())  # Ensure the model fit is valid
    # If model is NULL (e.g., identical x and y), show message
    if (is.null(fit())) {
      return(datatable(data.frame(Message = "Regression model could not be fit. Check your variable selections.")))
    }
    
    title <- paste("Effect of <strong>", input$xvar_track, "</strong> on <strong>", input$yvar_stream, "</strong>")
    
    # Tidy the model output and select only the necessary columns
    tidy_fit <- broom::tidy(fit_streams(), conf.int = TRUE) %>%
      select(term, estimate, std.error, conf.low, conf.high, p.value) %>%
      mutate(estimate=round(estimate, 3),
             std.error=round(std.error, 3),
             conf.low=round(conf.low, 3),
             conf.high=round(conf.high, 3),
             p.value=round(p.value, 3))
    
    
    tidy_fit$term <- c("Intercept", 
                       as.character(input$xvar),
                       input$controls_select)
    
    
    # Render the table with customized column names
    datatable(
      tidy_fit,
      colnames = c("Term", "Estimate", "Std. Error", "Lower 95% CI", "Upper 95% CI", "p-value"),
      class = 'compact',  # Makes the table more compact
      options = list(
        dom = 't',         # Display only the table without any controls
        pageLength = nrow(tidy_fit),  # Show all rows
        autoWidth = TRUE
      ),
      rownames=F,
      caption=HTML(title)
    )
  })
  
}