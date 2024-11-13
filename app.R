
library(tidyverse)
library(ggimage)
library(shiny)
library(broom)
library(bslib)
library(ggplot2)
library(ggExtra)
library(grid)
library(jpeg)
library(wordcloud2)
library(memoise)
library(tm)
library(markdown)
library(DT)

# Colors sampled from album covers
album_colors <- c("A Sun Came!"="#7b7644", "Michigan"="#d32831",
                  "Seven Swans"="#010508", "Illinois"="#4d758c",
                  "The Avalanche"="#e8681b", "The Age of Adz"="#ae3625",
                  "All Delighted People"="#b37f61", "Carrie & Lowell"="#334249",
                  "The Ascension"="#f8a139", "A Beginner's Mind"="#1769a1",
                  "Javelin"="#e688a3")

# Albums ordered by release date
album_levels <- c("A Sun Came!", "Michigan",
                  "Seven Swans", "Illinois",
                  "The Avalanche", "The Age of Adz",
                  "All Delighted People", "Carrie & Lowell",
                  "The Ascension", "A Beginner's Mind",
                  "Javelin")

# Accent colors sampled from album covers
album_colors_accents <- c("A Sun Came!"="#c3a8a3", "Michigan"="#b9d3c6",
                          "Seven Swans"="#010508", "Illinois"="#fbe956",
                          "The Avalanche"="#7793a8", "The Age of Adz"="#1b1d1a",
                          "All Delighted People"="#ffffff", "Carrie & Lowell"="#b7b396",
                          "The Ascension"="#33323a", "A Beginner's Mind"="#f1d76e",
                          "Javelin"="#a78f6b")

# Master dataset, renaming columns for prettiness
df_trackviz <- readRDS("Data/df_trackviz.rds") %>%
  rename(`Album`=album_name,
         `Duration (s)`=duration_s,
         `Track position in album (%)*`=track_starting_point_normalized,
         `Loudness (dB)`=loudness,
         `Tempo (bpm)`=tempo,
         `Sentiment (AFINN)`=net,
         `Number of words in lyrics`=num_of_words,
         `Words per minute`=words_per_minute,
         `Mean word length in lyrics`=mean_word_length,
         `Album release date`=release_date) %>%
  mutate(Album=factor(Album, levels=album_levels),
         `Mean word length in lyrics`=round(`Mean word length in lyrics`, 2))

# Subset of data for scatterplot
df_num <- df_trackviz %>% select(`Duration (s)`,
                                 `Track position in album (%)*`,
                                 `Loudness (dB)`,
                                 `Tempo (bpm)`,
                                 `Number of words in lyrics`,
                                 `Words per minute`,
                                 `Mean word length in lyrics`,
                                 `Sentiment (AFINN)`,
                                 `Album release date`)

# Subset of data for barplot
df_bar <- df_trackviz %>% select(`Duration (s)`,
                                 `Track position in album (%)*`,
                                 `Loudness (dB)`,
                                 `Tempo (bpm)`,
                                 `Number of words in lyrics`,
                                 `Words per minute`,
                                 `Mean word length in lyrics`,
                                 `Sentiment (AFINN)`)

# Data with streaming variables
df_streams <- df_trackviz %>% 
  left_join(readRDS("Data/sufjan_streams.rds"), by=c("name"="trackName")) %>% 
  mutate(across(c(n_streams:n_weekday_streams, total_msPlayed:total_sPlayed), 
                ~replace_na(., 0))) %>% 
  mutate(`Total min. played`=total_sPlayed/60) %>% 
  mutate(`Mean % of track played`=100*mean_sPlayed/duration_min) %>% 
  rename(
    `Num. of streams`=n_streams
  )

df_streams_dropdown_y <- df_streams %>% select("Num. of streams", "Total min. played", "Mean % of track played")

all_albums <- df_trackviz %>% pull(Album) %>% unique()

# Subset of data for wordcloud accompanying statistics
df_trackviz_wordcloud <- df_trackviz %>% select(name, id, Album, text,
                                                `Sentiment (AFINN)`,
                                                `Loudness (dB)`,
                                                `Tempo (bpm)`,
                                                `Number of words in lyrics`,
                                                `Mean word length in lyrics`,
                                                `Words per minute`,
                                                `Duration (s)`)

# Helper to build term matrix
getTermMatrix <- memoise(function(song) {
  if (!(song %in% unique(df_trackviz_wordcloud$name)))
    stop("Unknown song")

  text <- (df_trackviz_wordcloud %>% filter(name==song) %>% pull(text))[[1]]

  myCorpus = Corpus(VectorSource(text))
  myCorpus = tm_map(myCorpus, content_transformer(tolower))
  myCorpus = tm_map(myCorpus, removePunctuation)
  myCorpus = tm_map(myCorpus, removeNumbers)
  myCorpus = tm_map(myCorpus, removeWords,
                    c(stopwords("SMART"), "thy", "thou", "thee", "the", "and", "but"))

  myDTM = TermDocumentMatrix(myCorpus,
                             control = list(minWordLength = 1))

  m = as.matrix(myDTM)

  sort(rowSums(m), decreasing = TRUE)
})

# UI

ui <- navbarPage("SufjanViz", fluid=T,
                 tabPanel("Tracks",
                          fluidRow(
                            tags$head(tags$style(HTML(".selectize-input,
                                                      .selectize-dropdown,
                                                      .checkbox,
                                                      #smooth_type-label,
                                                      #margin_type-label,
                                                      #xvar-label,
                                                      #yvar-label {font-size: 75%;}"))),
                            column(3,
                                varSelectInput("xvar", "X variable", df_num, selected = "Duration (s)"),
                                varSelectInput("yvar", "Y variable", df_num, selected = "Tempo (bpm)"),
                                checkboxInput("exclude_instrumentals", "Exclude instrumental tracks", FALSE),
                                checkboxInput("by_albums", "Group by album", TRUE),
                                conditionalPanel(condition="input.by_albums==true",
                                                 checkboxInput("album_images", "Use album covers as points", FALSE),
                                                 conditionalPanel(condition="input.album_images==true",
                                                                  sliderInput("slider", "Point size",
                                                                              min = 0.001, max = 0.5, value = .03))),
                                checkboxInput("show_margins", "Show distributions", FALSE),
                                conditionalPanel(condition="input.show_margins==true",
                                                 selectInput("margin_type", "Type", list("Density", "Histogram"), "Density")),
                                checkboxInput("smooth", "Add smoothing"),
                                conditionalPanel(condition="input.smooth==true",
                                                 selectInput("smooth_type", "Smoothing function",
                                                             list("Linear"="lm", "Loess"="loess"), selected = "Linear")),
                                hr(), 
                                checkboxGroupInput(
                                  "Album", "Filter by album",
                                  choices = unique(df_trackviz$Album),
                                  selected = unique(df_trackviz$Album)
                                )
                              ),
                            column(6,
                              plotOutput("scatter"),
                              hr(),
                              DTOutput("regression_table")
                            ),
                            column(3,
                                   h6("Summary Statistics", align="center"),
                                   div(DT::DTOutput("table"), style="font-size:75%")
                                   )
                          )),
                 tabPanel("Albums",
                          page_sidebar(
                            tags$head(tags$style(HTML(".selectize-input,
                                                      .selectize-dropdown,
                                                      .checkbox,
                                                      #barvar-label {font-size: 75%;}"))),
                            mainPanel(
                              plotOutput("bar"),
                              hr(),
                              h6("Summary Statistics", align="center"),
                              div(DT::DTOutput("table_bar"), style="font-size:75%")
                            ),
                            sidebar=sidebar(
                              varSelectInput("barvar", "Variable", df_bar, selected = "Duration (s)"),
                              hr(),
                              checkboxGroupInput(
                                "Album_bar", "Filter by album",
                                choices = unique(df_trackviz$Album),
                                selected = unique(df_trackviz$Album)
                              )
                            )
                          )
                        ),
                 tabPanel("Lyrics",
                          tags$head(tags$style(HTML(".selectize-input,
                                                      .selectize-dropdown,
                                                      .checkbox,
                                                      #max-label,
                                                      #freq-label {font-size: 75%;}"))),
                          fluidRow(
                            column(3,
                            selectInput("wc_album", "Album", all_albums, selected="Illinois"),
                            selectInput("wc_song", "Song",
                                        choices = c("Chicago"), selected="Chicago"),
                            hr(),
                            sliderInput("freq",
                                        "Min Frequency:",
                                        min = 1,  max = 30, value = 1)
                           ),
                            column(6,
                              wordcloud2Output("wordcloud"),
                              hr(),
                              h6("Track Statistics", align=""),
                              div(DT::DTOutput("table_wc"), style="font-size:75%")
                            ),
                            column(
                              3, uiOutput("lyricColumn")
                            )
                          )
                        ),
                 tabPanel("Streaming",
                          fluidRow(
                            tags$head(tags$style(HTML(".selectize-input,
                                                      .selectize-dropdown,
                                                      .checkbox,
                                                      #smooth_type-label,
                                                      #margin_type-label,
                                                      #xvar-label,
                                                      #yvar-label {font-size: 75%;}"))),
                            column(3,
                                   varSelectInput("xvar_track", "Track variable", df_num, selected = "Duration (s)"),
                                   varSelectInput("yvar_stream", "Streaming variable", df_streams_dropdown_y, selected = "Num. of streams"),
                                   checkboxInput("exclude_instrumentals2", "Exclude instrumental tracks", FALSE),
                                   checkboxInput("by_albums2", "Group by album", TRUE),
                                   conditionalPanel(condition="input.by_albums==true",
                                                    checkboxInput("album_images2", "Use album covers as points", FALSE),
                                                    conditionalPanel(condition="input.album_images2==true",
                                                                     sliderInput("slider2", "Point size",
                                                                                 min = 0.001, max = 0.5, value = .03))),
                                   checkboxInput("show_margins2", "Show distributions", FALSE),
                                   conditionalPanel(condition="input.show_margins2==true",
                                                    selectInput("margin_type2", "Type", list("Density", "Histogram"), "Density")),
                                   checkboxInput("smooth2", "Add smoothing"),
                                   conditionalPanel(condition="input.smooth2==true",
                                                    selectInput("smooth_type2", "Smoothing function",
                                                                list("Linear"="lm", "Loess"="loess"), selected = "Linear")),
                                   hr(), 
                                   checkboxGroupInput(
                                     "Album2", "Filter by album",
                                     choices = unique(df_trackviz$Album),
                                     selected = unique(df_trackviz$Album)
                                   )
                            ),
                            column(6,
                                   plotOutput("scatter_streams"),
                                   hr(),
                                   DTOutput("regression_table")
                            ),
                            column(3,
                                   h6("Summary Statistics", align="center"),
                                   div(DT::DTOutput("table_streams"), style="font-size:75%")
                            )
                          )),
                 tabPanel("About",
                          mainPanel(
                            includeMarkdown("Data/aboutpage.md")
                          ))
)

# Server

server <- function(input, output, session) {


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

  # Scatter tab elements
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
    print(fit())
    # If model is NULL (e.g., identical x and y), show message
    if (is.null(fit())) {
      return(datatable(data.frame(Message = "Regression model could not be fit. Check your variable selections.")))
    }

    title <- paste("Effect of <strong>", input$xvar, "</strong> on <strong>", input$yvar, "</strong>")

    # Tidy the model output and select only the necessary columns
    tidy_fit <- broom::tidy(fit(), conf.int = TRUE) %>%
      select(term, estimate, std.error, conf.low, conf.high, p.value) %>%
      mutate(estimate=round(estimate, 2),
             std.error=round(std.error, 2),
             conf.low=round(conf.low, 2),
             conf.high=round(conf.high, 2),
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


  # Bar tab elements

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

  # Define a reactive expression for the document term matrix
  terms <- reactive({
    # Change when the "update" button is pressed...
    input$wc_song
    # ...but not for anything else
    isolate({
      withProgress({
        setProgress(message = "Processing corpus...")
        getTermMatrix(input$wc_song)
      })
    })
  })

  # Make the wordcloud drawing predictable during a session

  output$wordcloud <- renderWordcloud2({
    v <- data.frame(words=names(terms()), freq=terms()) %>%
            filter(ifelse(max(freq, na.rm=T) < input$freq, freq >= input$freq, freq>=0))

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
  
  subsetted_streams <- reactive({
    req(input$Album2)
    if(input$exclude_instrumentals2){
      df_streams %>% filter(Album %in% input$Album2, text != "")
    }
    else{
      df_streams %>% filter(Album %in% input$Album2)
    }
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
        if(input$smooth2) geom_smooth(method=input$smooth_type2, se=F),
        labs(color=""),
        if(input$xvar_track=="Track position in album (%)*") labs(caption="* Calculated as % of the way through the album's duration the track starts at.")
      )
    
    if (input$show_margins2) {
      p <- ggExtra::ggMarginal(p, type = tolower(input$margin_type2), margins = "both",
                               size = 8, groupColour = input$by_albums2, groupFill = input$by_albums2)
    }
    
    p
  }, res = 100)

}

shinyApp(ui, server)
