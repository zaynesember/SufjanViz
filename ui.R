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
                                   selectInput("wc_song", "Track",
                                               choices = c("Chicago"), selected="Chicago"),
                                   hr(),
                                   h6("Track Statistics", align=""),
                                   div(DT::DTOutput("table_wc"), style="font-size:75%")
                                   # hr(),
                                   # sliderInput("freq",
                                   #             "Min Frequency:",
                                   #             min = 1,  max = 30, value = 1)
                            ),
                            column(6,
                                   wordcloud2Output("wordcloud")
                                   # hr(),
                                   # h6("Track Statistics", align=""),
                                   # div(DT::DTOutput("table_wc"), style="font-size:75%")
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
                 tabPanel("About",
                          mainPanel(
                            includeMarkdown("Data/aboutpage.md")
                          ))
)
