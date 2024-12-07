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
library(tidytext)
library(purrr)

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
  mutate(`Total min. played`=total_sPlayed/60,
         `Percent of Sufjan streams`=share_of_suf_streams*100) %>% 
  mutate(`Mean % of track played`=100*mean_sPlayed/duration_min) %>% 
  rename(
    `Num. of streams`=n_streams
  )

df_streams_dropdown_y <- df_streams %>% select("Num. of streams", 
                                               "Percent of Sufjan streams", 
                                               "Total min. played", 
                                               "Mean % of track played")

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

# Creating color coded lyrics
# df_lyric_sentiment <- df_trackviz %>%
#   mutate(lyrics = str_replace_all(lyrics, "[\r\n]", "\n")) %>%  # Normalize line breaks
#   rowwise() %>%  # Process each row independently
#   mutate(lyrics = str_split(lyrics, "\n") %>%
#            map_chr(~ {
#              lines <- .
#              # Process each line of the lyrics, preserving empty lines
#              processed_lines <- lines %>% map_chr(~ {
#                if (is.na(.x) || str_trim(.x) == "") {
#                  return("<br/>")  # Preserve original empty lines as <br/>
#                }
#                tokens <- str_split(.x, "\\s+")[[1]]  # Split line into tokens
#                tokens <- map(tokens, function(token) {
#                  if (is.na(token) || token == "") {
#                    return("")  # Skip empty or missing tokens
#                  }
#                  
#                  # Separate punctuation and main token
#                  punctuation <- str_extract(token, "[[:punct:]]*$")  # Extract punctuation
#                  stripped_token <- str_remove_all(token, "[[:punct:]]")  # Remove punctuation
#                  
#                  if (stripped_token == "") {
#                    # If only punctuation, display it in dark gray
#                    return(sprintf("<span style='color: rgba(64, 64, 64, 1);'>%s</span>", token))
#                  }
#                  
#                  # Get sentiment score for the stripped token
#                  sentiment <- get_sentiments("afinn") %>%
#                    filter(word == tolower(stripped_token)) %>%
#                    pull(value) %>% 
#                    first(default = 0)  # Get sentiment value, default 0
#                  
#                  # Determine color
#                  color <- case_when(
#                    sentiment > 0 ~ sprintf("rgba(%d, %d, %d, 1)", 200 - (sentiment * 20), 0, 0),
#                    sentiment < 0 ~ sprintf("rgba(0, 0, %d, 1)", 200 + (sentiment * 20)),
#                    TRUE ~ "rgba(64, 64, 64, 1)"  # Dark Gray for neutral
#                  )
#                  
#                  # Combine token and punctuation, and wrap in HTML span
#                  sprintf("<span style='color: %s;'>%s</span><span style='color: rgba(64, 64, 64, 1);'>%s</span>", 
#                          color, stripped_token, punctuation)
#                })
#                
#                # Recombine the tokens into a line
#                paste(tokens, collapse = " ")
#              })
#              # Only add <br/> between non-empty processed lines, preserving intentional empty lines
#              paste(processed_lines, collapse = "")
#            })) %>%
#   ungroup() %>%
#   select(id, lyrics)  # Retain only id and formatted lyrics

#saveRDS(df_lyric_sentiment, "../GitRepos/SufjanViz/Data/df_lyric_sentiment.rds")
df_lyric_sentiment <- readRDS("../GitRepos/SufjanViz/Data/df_lyric_sentiment.rds")

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