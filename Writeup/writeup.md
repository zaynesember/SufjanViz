---
editor_options: 
  markdown: 
    wrap: 72
---

# Motivation

I undertook this project for three reasons (other than wanting to work
on something other than my dissertation):

1.  As a music lover and instrument-hoarder, I've wanted to do a data
    science project using Spotify data for a while. Spotify Wrapped is
    fine and all but for those spending way too much time thinking about
    statistics it's super limited and provides little insight into the
    user's music listening habits, particularly what characteristics of
    music determine what streaming behavior.

2.  As a music lover, I'm also interested in what patterns in an
    artist's discography can be gleaned quantitatively. Any dedicated
    fan observes patterns subjectively as they listen to their favorite
    artist but to what degree can these be verified?

3.  Much of my dissertation research focuses on merging variables
    constructed from natural language processing with other
    cross-sectional and longitudinal data so I'm always on the hunt for
    projects requiring similar methods. However, this project was much
    more motivated by wanting to try something I'd never done before:
    building an interactive dashboard. How data analyses are presented
    in academic research is generally very different from how a data
    scientist presents results to stakeholders in a business setting.
    With SufjanViz I try to present results in an approachable way using
    fairly simple methods while also giving the user the opportunity to
    customize the analyses to their liking.

# Data

The data for this project is drawn primarily from Spotify, both from
their API using
[spotifyr](https://cran.r-project.org/web/packages/spotifyr/index.html),
and from a takeout of my own streaming data. I supplement this with
lyric data and album art collected from
[Genius](https://genius.com/artists/Sufjan-stevens). I choose to
restrict my analyses to the tracks on Sufjan's major LP and EP projects
that contain lyrics, that is to say I exclude his sizable Christmas
catalog which is largely composed of covers, his ambient music albums,
his instrumental-only albums, *Carrie & Lowell Live*, his mixtape *The
Greatest Gift* which is primarily demos or remixes of tracks from
*Carrie & Lowell*, and his collaboration with James McAlister, Nico
Muhly, and Bryce Dessner, *Planetarium*, which is primarily
instrumental. I do include his collaborative album, *A Beginner's Mind*,
with Angelo De Augustine due to it being a mainstream release consistent
with Sufjan's other indie folk releases. This is all to say I am not
analyzing the *entirety* of his discography but instead what I think is
most representative of his work as a mainstream artist. In the end, I
consider 160 tracks from 11 albums and pair it with my own streaming
history from September 2023 to September 2024.

From here I present two sets of priors and findings: The first concerns
the artistry of Sufjan Stevens--as a dedicated listener (evidenced by Figure 0, 
my 2024 Spotify Wrapped) of Sufjan's music I feel I have a good sense of
the patterns present in his discography but before doing this project
this was based mostly on vibes. What does the data say? The second
concerns my own listening behavior. Why do I prefer some songs over
others? Is this a result of clear preferences for songs with certain
traits over others? Or is it just a matter of subjective preference
linked to when I first heard the song and what memories and emotions I
associate it with?

# Sufjan's Musical Tendencies

## Prior 1: Sufjan's style varies significantly album to album in some ways but maintains certain musical themes

Those who are only vaguely aware of Sufjan's music probably would
characterize his style as being sadcore indie folk with whispered vocals
and plucky acoustic arrangements. This certainly isn't unfair, at least
for his more recent and best known tracks like "Fourth of July" off
*Carrie & Lowell* or "Mystery of Love" from the *Call Me By Your Name*
soundtrack. However, hardcore fans will recognize that Sufjan delves
into quite different sounds on different albums in ways we would expect
to be reflected in the data.

### Loudness

One place I'd expect this to manifest is in the average loudness across
tracks on each album. Albums relying on scarcer, acoustic arrangements
like *Seven Swans* and *Carrie & Lowell* will be quieter than the rich,
electronic arrangements found on *The Age of Adz* or the orchestral
arrangements full of horns and strings on many of the tracks from
*Illinois*. I would, however, expect that *Illinois* would have the most
variation in loudness across tracks because, while tracks like "Chicago"
and "Come On! Feel the Illinoise! Part I: The World’s Columbian
Exposition, Part II: Carl Sandburg Visits Me in a Dream" (yes, that's
the actual title) are rather bombastic, the album also features softer,
sadder cuts like "John Wayne Gacy, Jr.", "The Seer's Tower", and
"Casimir Pulaski Day".

#### Findings

Upon inspection of Figure 1, one thing is immediately clear: despite my
expectations, *Carrie & Lowell* is considerably louder than the other
albums. This is a bit puzzling since it's certainly *perceived* by fans
to be his "softest" album. This finding is confirmed by Table 1, giving
the mean loudness for *Carrie & Lowell* as -21.79 dB, over 7 dB louder
than the next loudest album, *Michigan*. Further, the difference in
means is statistically significant (*p*\<.001). Also contrary to
expectations is the finding that *The Age of Adz* is not one of the louder
albums analyzed.

What is fairly consistent with my priors is that *Illinois* boasts the
second largest amount of variation in loudness across tracks, beaten out
only by *A Sun Came!*. However, there is an interesting trend in
loudness variation. Turning to Figure 2, we can see that after
*Illinois* there is a significant drop-off in variation. This is
especially curious given the first album for which we observe less
variation is *The Avalanche*–a companion album to *Illinois* containing
outtakes from the album. Why would there be such a drastic change in
variation for songs recorded in the same sessions for the same album?

Some digging leads to a potential answer from a 
[2006 interview with *Pitchfork*](https://web.archive.org/web/20160303215709/http://pitchfork.com/features/interviews/6335-sufjan-stevens/)
where Sufjan says about *The Avalanche*:

>I did some things I didn't do before: A lot of it was finished and I had
recorded the drums myself, and I wasn't really happy with my
performance, so I sent them to James McAllister in Seattle and had him
perform drum tracks and have a different engineer record it. I hadn't
ever sent material to have someone else record it and be in charge of
how it would sound [. . .] About six of the songs were totally finished,
and then more than half of it was modified. The editing, re-recording,
and engineering I did afterward redeemed a lot of the material.

This leads me to believe the change in variation is a result of Sufjan evolving
his production practices while finishing the album and carrying those practices
through subsequent albums.

Yet this doesn't explain why *Carrie & Lowell* is so much louder than other
albums. I have two theories:

1. The album was released in 2015, the same year Apple Music entered the music
streaming market. Though music streaming services like Spotify had already
been operating for a decade, most consumers used services that downloaded
audio files locally like Napster and iTunes. The entrance of Apple Music could
be considered a turning point in the music industry and may have influenced
mixing decisions in some way. However, I'm skeptical of this given Sufjan was
not sending his master recordings off to a major record label to distribute,
rather he is signed to the independent label Asthmatic Kitty Records owned by
himself and his stepfather (the Lowell of *Carrie & Lowell*).

2. The album is mixed to be louder intentionally because the instrumentation
and vocals are so soft. I am by no means a sound engineer, though I have dabbled
in recording and mixing, but the white noise that permeates several tracks 
(i.e. "The Only Thing") from the album certainly sound like the ambient sound 
that results from cranking the loudness of a track up. 

Either way, the choice to mix the album to be so much louder than the others
certainly seems intentional.

### Tempo

Like loudness, I expect the tempo across albums to vary. While
at first thought it seems intuitive that Sufjan's sadder acoustic folk
albums would be slower on average, I suspect the opposite may be the
case. Albums like *Seven Swans* and *Carrie & Lowell* feature tracks
that, though having softer instrumentation, tend to chug along at a
quick pace carried by the acoustic guitar's complex fingerpicking
patterns. "Carrie & Lowell" and "Death with Dignity" are both great
examples of this. Meanwhile, the style employed on *Michigan* is much
more meandering with tracks like "Flint (For the Unemployed and
Underpaid)" and "Oh God Where Are You Now? (In Pickerel Lake? Pigeon?
Marquette? Mackinaw?)" carried by a slow, gentle piano

#### Findings

From Figure 3 alone it is difficult to determine whether average tempo differs
significantly across albums, although it does appear my intuition that
*Carrie & Lowell* is on the faster side. While we could just look at the mean
track tempo for each album, this measure perhaps isn't the best
operationalization of the concept we're actually interested in, i.e. how fast
an album is overall. An album's longest tracks could be allegro but if a couple
short tracks on the album are legato then the mean will give us the impression
the album overall is moderato. The issue is that a simple mean does not account
for track length--to do so we need a weighted mean which better captures how
fast or slow an album is overall. 

Figure 4 plots the weighted and unweighted mean for each album. Note that unlike
for other measures, the Spotify API reports a measurement error for tempo since
unlike more "objective" measures like loudness and track duration, tempo is
estimated with some sort of algorithm. Immediately striking is the difference in
error bar sizes between the unweighted and weighted means. The unweighted means
have far larger uncertainties because the tracks with the largest reported error
are interludes like "One Last “Whoo-Hoo!” for the Pullman" which have no
discernible tempo.

Looking at the weighted means in Figure 4, we see that *Seven Swans* and
*The Age of Adz* are the fastest albums as expected and not far behind are *Javelin*
and *Carrie & Lowell*. *Michigan*, as predicted, is among the slowest albums. 
Interestingly, the albums do not vary considerably in tempo when looking at the 
weighted mean with most albums hovering around 125 bpm which in music lingo is 
allegro or fast. It is suprising how little variation there is in mean tempo
across albums considering how much they vary in musical style and theme.

## Prior 2: Track characteristics are correlated

Despite differences across albums, I expect that certain track
characteristics will be correlated across Sufjan's discography. It's
common knowledge that musical characteristics like key and chord
progression evoke certain emotions–at least within the artist's culture.
It's reasonable to assume that if Sufjan employs a certain
characteristic to convey an emotion, he would complement it with other
characteristics that reinforce the emotion.

(Sidenote: Interestingly, what emotion is evoked seems to be at least
partly dependent on one's culture. For example, in Western cultures
minor keys are associated with sadness but this is not universally true
across cultures, see [Singh and Mehr
2023](https://pmc.ncbi.nlm.nih.gov/articles/PMC10745197/).)

I expect Sufjan is not only intentional in evoking emotions for
individual tracks, but in crafting an overall arc in his albums. His
frequent use of instrumental segues to transition one song to the next
indicate care for thematic progression of albums. Anecdotally, his
albums tend to ramp up, reaching a climax with his longer, more
bombastic tracks, before winding down to end on a more low key note.
Because of this, I expect a track's position in the album will be
correlated with other characteristics that help convey this arc.

### Sentiment

I suspect that the sentiment of a song's lyrics will be correlated with
certain other track statistics. My anecdotal observation is that
Sufjan's longer tracks tend to be more upbeat, or at least contain
upbeat movements with corresponding upbeat lyrics, like "Impossible
Soul" and "Come on! Feel the Illinoise!". For this reason I expect
longer tracks will on average have more positive sentiment in their
featuring layered refrains in canon and dense verses. As such I also
expect that the more words per minute in a track (which is effectively
the total number of lyrics controlling for track duration), the more
positive the sentiment will be.

#### Findings

From Figure 5 we see there is a weak correlation between sentiment and track 
duration (*p*<.1)--longer tracks do tend to have more positive sentiment in
their lyrics. Likewise, in Figure 6 there is a weak correlation between
sentiment and words per minute (*p*<.11). There does appear to be something of a
systematic difference between tracks with different emotional tones in their
lyrics.

However, I am not extremely confident in these results--and not just because of
their borderline statistical significance. Inspection of which sentiment lyrics
are associated with in the AFINN dictionary through the color-coded lyrics in
the Lyrics tab of the dashboard raises further questions. For one, few lyrics
are coded as anything other than neutral. In addition, Sufjan employs a lot of,
for lack of a better term, weird words and proper nouns to create imagery and
reinforce themes in his music. Much of the sentiment conveyed by the lyrics may
then be missed by the current sentiment analysis approach.

### Track Position

Because his albums tend to end on a more downbeat note, I expect that
tracks toward the end of an album will have a slower tempo and
fewer words per minute. This relationship may, however, be curvilinear
since I also suspect his albums open with downbeat songs to create the
aforementioned thematic arc.

#### Findings

From Figure 7 we see that, as expected, there is a slightly negative correlation
(*p*<.1) between a track's position in the album and its tempo indicating that
the albums tend to slow down as they progress. However, contrary to my prior,
Figure 8 shows there is no statistically significant relationship between track 
position and words per minute (when excluding instrumental tracks).

However, this is only testing for a linear relationship between the variables.
I would expect that songs at both the beginning and end of the album would have
slower tempo than those in the middle. I try two approaches to test for this
kind of relationship: First, I create an indicator variable for whether a track
is in the first or last quarter of an album and regress that on tempo--this
yields null results. I also try an indicator for the first and last third as
well as the first and last tenth, both of which still yield null results. 

These cutoffs are, of course, arbitrary and don't really enable us to model the
underlying relationship we suspect might be there. To do this more properly I
estimate a quadratic regression which is just fancy statistics speak for
including the square of the independent variable in the model. This too gives a 
null result leaving me to conclude that there does not seem to be a systemic
arc in tempo across albums.


# Prior 3: My listening behavior is correlated with measurable track qualities

### Sentiment

Given my perception that I prefer the sadder parts of Sufjan's discography, I 
expect songs with more negative sentiment in their lyrics to have more total 
streams. I also expect I will be more likely to listen to them all the way 
through. 

#### Findings

Figures 9 and 10 show the relationship between lyric sentiment and my
streaming behavior, revealing no significant correlation. As discussed
earlier, however, this may be more a reflection of the sentiment dictionary not
accurately reflecting the actual emotional content of songs.

### Words per minute

Because I tend to prefer Sufjan's tracks with dense and loquacious
lyrics like those found on *Illinois* and *Michigan*, I expect that
songs with more words per minute and with longer words on average will
have been streamed more frequently.

#### Findings

While I find no relationship between words per minute and streaming frequency,
from Figure 11 we see there is a positive correlation between mean word length
and streaming frequency as expected. The data seems to back up my prior that I
prefer Sufjan's tracks featuring more lyrical intricacy. There is still a bit of
a surprise, however--this relationship is not driven by tracks from *Illinois*
and *Michigan*. Rather it seems my obsession with tracks like "Everything That 
Rises" and "Will Anybody Ever Love Me?" since the release of *Javelin* do. This
is confirmed by Table 2 where I estimate the same regression with *Javelin* 
tracks removed--the coefficient is still positive however no longer significant
(which, to be fair, in part just reflects less power from the restricted sample
size).

# Lessons and Next Steps

It was a lot of fun learning how to create a Shiny dashboard for this project
and to finally make use of some data I have been sitting on for a good while. 
Some things I learned along the way:

- **Dynamic data visualization works a different muscle than putting together
static plots for a paper.** While I have always enjoyed endlessly tweaking plots
to make them aesthetically pleasing and comprehensible, I never got much into
dynamic or interactive plots beyond making a 3-D scatter plot. Deciding what
customization options to include and how to implement them was an interesting
challenge that required thinking through what a stakeholder using the dashboard
would want rather than just what I wanted to see.
- **GenAI is a great tool but still has shortcomings.** This project was the
first time I used OpenAI's GPT (namely o-1) in a significant way. This was not
quite the same as learning a whole new language with it since I am very
comfortable in `R`, but it was the first time since undergrad I worked on a web 
app and so there were new mechanics (namely reactive environments and observable 
events) I had to get used to. I was really impressed by how well the GPT could
follow my instructions and spit out code giving UI elements I requested and
even building working UI elements that dynamically changed plots. While I still
had to rely on StackOverflow and documentation to fully grasp what was
happening, with GPT alone I could get pretty far and learn a good amount. I
still don't think using a GPT exclusively would be sufficient for someone with
no or little programming experience but I now feel that I could pick up another
language fairly quickly with its help. This is not to say there aren't problems--
there were many times when I was given broken code that it could not seem to fix
or it told me blatantly incorrect ways to fix bugs. At the end of the day you
still have to understand absolutely everything happening in your code to ensure
a stable and functional product . . . but some day soon this may not be the
case.
- **Your priors even about data you're intimately familiar with can be wrong.**
As evidenced from a number of my hypotheses finding no support, even when in a
domain you're an "expert" in you can absolutely be incorrect, or at least find
no evidence you are correct. In hindsight this seems obvious since as a PhD
candidate I have run my fair share of regressions with null results but it was a
reminder to not my assumptions about the world and even my own behavior as
ground truth.

There are a number of limitations to this project that, if time allows, I would
like to address to make for a more thorough analysis and just to think more
about how I can use and present this data:

- **Sample size of one artist:** The clearest limitation here is only looking at
one artist's discography. I would love to extend the analysis to artists in the
same sphere as Sufjan like Bon Iver, or in different genres entirely.
- **Extended streaming history:** The streaming data from my Spotify data
takeout is limited to September 2023 to September 2024. One year of data is
pretty decent but more is usually better and a particular issue with this date
range is that Sufjan released *Javelin* in October 2023, heavily skewing the
results given I have been listening to the album consistently since. Revisiting
this project down the line with one or two more years of data would be neat.
- **Improving sentiment measurement:** A glaring improvement needed for this
project is a better method for estimating the emotional sentiment of song
lyrics. I need to do more research on the accepted dictionaries/methods for 
getting the sentiment of shorter, literary texts like the song lyrics I use
here.
- **Making use of additional data:** I did not use all the data I initially
collected for this project. Notably I have a community-sourced dataset of the
time signatures of the discography. As someone with limited music theory
knowledge it felt a bit daunting to tackle that data or collecting further
musical data (namely keys, instruments used, and chord sequences) that could
make for a really cool analysis that dives more into the actual music. I also
constructed a number of variables intending to analyze the seasonality of my
listening habits as I have some priors about them but did not get a chance
to conduct the analyses.

With all that said, thank you for checking out this project and please get in
touch if you have any questions or spot any bugs!

Note: Supplemental analyses conducted for this writeup can be found [here](https://github.com/zaynesember/SufjanViz/blob/main/Writeup/SupplementalAnalysis.Rmd).
