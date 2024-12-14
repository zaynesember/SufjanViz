# Motivation

I undertook this project for three reasons (other than wanting to work on something other than my dissertation):

1. As a music lover and instrument-hoarder, I've wanted to do a data science project using Spotify data for a while. 
Spotify Wrapped is fine and all but for those spending way too much time thinking about statistics it's super limited
and provides little insight into the user's music listening habits, particularly what characteristics of music determine
what streaming behavior.

2. As a music lover, I'm also interested in what patterns in an artist's discography can be gleaned quantitatively. 
Any dedicated fan observes patterns subjectively as they listen to their favorite artist but to what degree can these be verified?

3. Much of my dissertation research focuses on merging variables constructed from natural language processing with other 
cross-sectional and longitudinal data so I'm always on the hunt for projects requiring similar methods. 
However, this project was much more motivated by wanting to try something I'd never done before: building an interactive dashboard.
How data analyses are presented in academic research is generally very different from how a data scientist presents results to 
stakeholders in a business setting. With SufjanViz I try to present results in an approachable way using fairly simple methods while
also giving the user the opportunity to customize the analyses to their liking.

# Data

The data for this project is drawn primarily from Spotify, both from their API using [spotifyr](https://cran.r-project.org/web/packages/spotifyr/index.html),
and from a takeout of my own streaming data. I supplement this with lyric data and album art collected from [Genius](https://genius.com/artists/Sufjan-stevens).
I choose to restrict my analyses to the tracks on Sufjan's major LP and EP projects that contain lyrics, that is to say I exclude his sizable Christmas catalog which is largely
composed of covers, his ambient music albums, his instrumental-only albums, *Carrie & Lowell Live*, his mixtape *The Greatest Gift* which is primarily demos or remixes of
tracks from *Carrie & Lowell*, and his collaboration with James McAlister, Nico Muhly, and Bryce Dessner, *Planetarium*, which is primarily instrumental.
I do include his collaborative album, *A Beginner's Mind*, with Angelo De Augustine due to it being a mainstream release consistent with Sufjan's other indie folk releases.
This is all to say I am not analyzing the *entirety* of his discography but instead what I think is most representative of his work as a mainstream artist.
In the end, I consider 160 tracks from 11 albums and pair it with my own streaming history from September 2023 to September 2024.

From here I present two sets of priors and findings: The first concerns the artistry of Sufjan Stevens--as a dedicated listener 
(evidenced by my 2024 Spotify Wrapped) of Sufjan's music I feel I have a good sense of the patterns present in his discography but before
doing this project this was based mostly on vibes. What does the data say? The second concerns my own listening behavior. 
Why do I prefer some songs over others? Is this a result of clear preferences for songs with certain traits over others?
Or is it just a matter of subjective preference linked to when I first heard the song and what memories and emotions I associate it with?

# Sufjan's Musical Tendencies

## Priors

  - Sufjan's style varies significantly album to album, i.e. tempo, arrangement, 
    but with common threads through them, i.e. bird references and certain chord progressions
  - Certain albums are sonically and lyrically similar, most notably Michigan and Illinois, but also ADP and Javelin
  - Certain albums are more depressing, namely Carrie & Lowell, and so would expect them to differ systematically from
    others that feature both sad and upbeat songs
    
## Prior 1: Sufjan's style varies significantly album to album in some ways but maintains certain musical themes

Those who are only vaguely aware of Sufjan's music probably would characterize his style as being sadcore 
indie folk with whispered vocals and plucky acoustic arrangements. This certainly isn't unfair, at least for his more
recent and best known tracks like "Fourth of July" off *Carrie & Lowell* or "Mystery of Love" from the *Call Me By Your Name* soundtrack.
However, hardcore fans will recognize that Sufjan delves into quite different sounds on different albums in ways we would expect to
be reflected in the data. 

### Loudness

One place I'd expect this to manifest is in the average loudness across tracks on each album. 
Albums relying on scarcer, acoustic arrangements like *Seven Swans* and *Carrie & Lowell* will be quieter than the rich, 
electronic arrangements found on *Age of Adz* or the orchestral arrangements full of horns and strings on many of the tracks from
*Illinois*. I would, however, expect that *Illinois* would have the most variation in loudness across tracks because, while tracks like "Chicago"
and "Come On! Feel the Illinoise! Part I: The World’s Columbian Exposition, Part II: Carl Sandburg Visits Me in a Dream" (yes, that's the actual song name)
are rather bombastic, the album also features softer, sadder cuts like "John Wayne Gacy, Jr.", "The Seer's Tower", and "Casimir Pulaski Day".

#### Findings

### Tempo

Like loudness, I expect the average tempo across albums to vary. While at first thought it seems intuitive that Sufjan's sadder 
acoustic folk albums would be slower on average, I suspect the opposite may be the case. Albums like *Seven Swans* and *Carrie & Lowell*
feature tracks that, though having softer instrumentation, tend to chug along at a quick pace carried by the acoustic guitar's complex fingerpicking patterns.
"Carrie & Lowell" and "Death with Dignity" are both great examples of this. Meanwhile, the style employed on *Michigan* is much more meandering with
tracks like "Flint (For the Unemployed and Underpaid)" and "Oh God Where Are You Now? (In Pickerel Lake? Pigeon? Marquette? Mackinaw?)" carried by
a slow, gentle piano

#### Findings

mention I'm not accounting for reported uncertainty in tempo, also fact Sufjan uses odd time signatures like Concerning the UFO sighting

Also point out a better measure would be a weighted average by the track duration

### Sentiment

I suspect that the sentiment of a song's lyrics will be correlated with other track statistics.
My anecdotal perception is that Sufjan's longer tracks tend to be more upbeat,
or at least contain upbeat parts, like "Impossible Soul" and "Come on Feel the Illinoise".

TODO: put full track title above

#### Findings

# Prior 2: My listening behavior is correlated with measurable track qualities


## Priors

- I listen to sadder Sufjan songs later in the day and during the winter
- I'm more likely to make it all the way through songs with more words per minute
- I listen to the least Sufjan in the summer

### Sentiment

Given my perception is that I prefer the sadder parts of Sufjan's discography,
I expect songs with more negative sentiment in their lyrics to have more total streams and
to be more likely to be listened to all the way through.

#### Findings

### Words per minute

Because I tend to prefer Sufjan's tracks with dense and loquacious (?) lyrics like those found
on *Illinois* and *Michigan*, I expect that songs with more words per minute and with longer lyrics
on average will have been streamed more often.

#### Findings

# Shortcomings and Next Steps

- Clearest limitation is only doing 1 artist, would like to extend to artists adjacent to Sufjan that I also
  listen to like Bon Iver, Angelo De Augustine
- Streaming history is limited from September 2023 to September 2024 and is likely biased because Javelin was released in October 2023
  - Also biased by roadtrip playing a shared playlist
- Analyzing chord sequences
- sentiment is based on a small subset of lyrics, especially given Sufjan uses a lot of proper nouns
that signal sentiment in a way not caught through sentiment analysis

TODO: other sentiment measure, add in seasonal data
