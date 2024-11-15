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