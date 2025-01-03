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
                                   "Plot and estimate the relationship between track-level variables",
                                   hr(),
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
                          fluidRow(
                            tags$head(tags$style(HTML(".selectize-input,
                                                      .selectize-dropdown,
                                                      .checkbox,
                                                      #barvar-label {font-size: 75%;}"))),
                            column(3,
                                   "Compare track-level variables across albums",
                                   hr(),
                                   varSelectInput("barvar", "Variable", df_bar, selected = "Duration (s)"),
                                   hr(),
                                   checkboxGroupInput(
                                     "Album_bar", "Filter by album",
                                     choices = unique(df_trackviz$Album),
                                     selected = unique(df_trackviz$Album)
                                    )
                                   ),
                                   column(6,
                                          plotOutput("bar"),
                                          hr(),
                                          h6("Summary Statistics", align="center"),
                                          div(DT::DTOutput("table_bar"), style="font-size:75%") 
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
                                   "View lyric frequency and sentiment by track",
                                   hr(),
                                   selectInput("wc_album", "Album", all_albums, selected="Illinois"),
                                   selectInput("wc_song", "Track",
                                               choices = c("Chicago"), selected="Chicago"),
                                   hr(),
                                   h6("Track Statistics", align=""),
                                   div(DT::DTOutput("table_wc"), style="font-size:75%")
                            ),
                            column(6,
                                   wordcloud2Output("wordcloud")
                            ),
                            column(
                              3,
                              HTML("<span style='color: rgba(200, 0, 0, 1); font-size: 10px;'>positive</span> 
                                <span style='color: rgba(200, 0, 0, 1); font-size: 10px;'>sentiment</span>, 
                                <span style='color: rgba(0, 0, 200, 1); font-size: 10px;'>negative</span> 
                                <span style='color: rgba(0, 0, 200, 1); font-size: 10px;'>sentiment</span>"
                                   ),
                              uiOutput("lyricColumn")
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
                                   "Plot and estimate the relationship between track-level and (my) streaming history variables",
                                   hr(),
                                   varSelectInput("xvar_track", "Track (X) variable", df_num, selected = "Duration (s)"),
                                   varSelectInput("yvar_stream", "Streaming (Y) variable", df_streams_dropdown_y, selected = "Num. of streams"),
                                   checkboxInput("controls", "Add control variables", FALSE),
                                   conditionalPanel(condition="input.controls==true",
                                                    checkboxGroupInput("controls_select", "",
                                                                       choices=NULL)),
                                   hr(),
                                   checkboxInput("exclude_instrumentals2", "Exclude instrumental tracks", FALSE),
                                   checkboxInput("by_albums2", "Group by album", FALSE),
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
                                   DTOutput("regression_table_streams")
                            ),
                            column(3,
                                   h6("Summary Statistics", align="center"),
                                   div(DT::DTOutput("table_streams"), style="font-size:75%")
                            )
                          )),
                 tabPanel("Write-up",
                          fluidRow(
                            column(7,
                            includeMarkdown("Writeup/writeup.md")
                            ),
                            column(5,
                                   div(style = "height:400px"),
                                   tags$figure(
                                     img(src='fig0_wrapped.png', align = "center",
                                         height="50%", width="50%"),
                                     tags$figcaption("Fig 0: My Spotify Wrapped")),
                                   div(style = "height:25px"),
                                   tags$figure(
                                     img(src='fig1_loudness_by_album.png', align = "center",
                                       height="80%", width="80%"),
                                       tags$figcaption("Fig. 1: Track Loudness Across Albums")),
                                   div(style = "height:25px"),
                                   tags$figure(
                                     img(src='tab1_loudness_by_album.png', align = "center",
                                         height="80%", width="80%"),
                                     tags$figcaption("Table 1: Album Loudness Summary")),
                                   div(style = "height:25px"),
                                   tags$figure(
                                     img(src='fig2_loudness_sd.png', align = "center",
                                         height="80%", width="80%"),
                                     tags$figcaption("Fig. 3: Loudness Variation")),
                                   div(style = "height:25px"),
                                   tags$figure(
                                     img(src='fig3_tempo_by_album.png', align = "center",
                                         height="80%", width="80%"),
                                     tags$figcaption("Fig. 3: Track Tempo Across Albums")),
                                   div(style = "height:25px"),
                                   tags$figure(
                                     img(src='fig4_tempo_weights.png', align = "center",
                                         height="80%", width="80%"),
                                     tags$figcaption("Fig. 4: Mean Album Tempos")),
                                   div(style = "height:25px"),
                                   tags$figure(
                                     img(src='fig5_sentiment_duration.png', align = "center",
                                         height="80%", width="80%"),
                                     tags$figcaption("Fig. 5: Track Sentiment and Duration")),
                                   div(style = "height:25px"),
                                   tags$figure(
                                     img(src='fig6_sentiment_duration.png', align = "center",
                                         height="80%", width="80%"),
                                     tags$figcaption("Fig. 6: Track Sentiment and Words per Minute")),
                                   div(style = "height:25px"),
                                   tags$figure(
                                     img(src='fig7_position_tempo.png', align = "center",
                                         height="80%", width="80%"),
                                     tags$figcaption("Fig. 7: Track Position and Tempo")),
                                   div(style = "height:25px"),
                                   tags$figure(
                                     img(src='fig8_position_wpm.png', align = "center",
                                         height="80%", width="80%"),
                                     tags$figcaption("Fig. 8: Track Position and Words per Minute")),
                                   div(style = "height:25px"),
                                   tags$figure(
                                     img(src='fig9_sentiment_streams.png', align = "center",
                                         height="80%", width="80%"),
                                     tags$figcaption("Fig. 9: Track Sentiment and Num. of Streams")),
                                   div(style = "height:25px"),
                                   tags$figure(
                                     img(src='fig10_sentiment_percplayed.png', align = "center",
                                         height="80%", width="80%"),
                                     tags$figcaption("Fig. 10: Track Sentiment and Mean % Played")),
                                   div(style = "height:25px"),
                                   tags$figure(
                                     img(src='fig11_wordlength_streams.png', align = "center",
                                         height="80%", width="80%"),
                                     tags$figcaption("Fig. 11: Num. of Streams and Mean Word Length")),
                                   div(style = "height:25px"),
                                   tags$figure(
                                     img(src='tab2_mwl.png', align = "ccenter",
                                         height="50%", width="50%"),
                                     tags$figcaption("Table 2: Num. of Streams and Mean Word Length (No Javelin)")),
                                   ),
                          )
                 ),
                 tabPanel("About",
                          mainPanel(
                            includeMarkdown("Writeup/aboutpage.md")
                          ))
)
