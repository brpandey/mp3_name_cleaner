# MP3NameCleaner

 Many aeons ago I was the Content Ingestion Program Manager for the inaugural [AmazonMP3](http://www.amazonmp3.com) service setting up the music service with its first 2 million tracks over the course of a year.
 
 I worked with digital music aggregators (e.g. [CDBaby](http://www.cdbaby.com/), , Naxos, The Orchard), the big labels (e.g. Warner, Sony) to get this done.

 And to this day, I still love and use MP3s!  :sparkles:

 Here's a little side script I wrote over a few days in a young functional language called [Elixir](http://elixir-lang.org/) at a local Starbucks coffee shop to clean MP3 file names.

## Description

 Straightforward script written in Elixir, using Elixir Streams, Enums, and Regexs

 Performs a non-destructive update copy of the original file set with cleaned up names

 Also provides support for title-casing, whitespace trimming, 
 extraneous info removal e.g. text in parens or brackets or curly braces

 The script *cleans* up mp3 file names given the assumptions:
 
 - [x]  The song info types e.g. Artist Name, Song Title, Album Name, Year are delimited by a hyphen
 - [x]  The Artist names and Song names are generally first.
 - [x]  The file contains a .mp3 suffix

 For example: 

 The names to the left of the arrow are uncleaned. Those on the right are cleaned up!

 > MALO - SUAVECITO -LIVE AUDIENCE - 1972.mp3 => Malo - Suavecito.mp3

 > Toto - Africa-1982.mp3 => Toto - Africa.mp3

 > Spacehog - In the Meantime (A)-Resident Alien.mp3 => Spacehog - In The Meantime.mp3

 > 'Groove Theory' - TELL me [Album Version]-1995.mp3 => Groove Theory - Tell Me.mp3

 > SWV - I'm So Into You-1992-It's about time.mp3 => SWV - I'm So Into You.mp3


# USAGE: 

Two modes:
 
1.  Simulation - test it out
2.  Update - performs actual non-destructive update - requires specifying root directory. 
    Also requires creating a directory called "Source" under the root dir as well as a 
    directory called "Renamed".  Please put the files to be cleaned under the source directory


Simulation

```$ ./mp3_name_cleaner --simulate "MALO - SUAVECITO -LIVE AUDIENCE - 1972.mp3 Toto - Africa-1982.mp3"
%{"MALO - SUAVECITO -LIVE AUDIENCE - 1972.mp3" => "Malo - Suavecito.mp3",
  "Toto - Africa-1982.mp3" => "Toto - Africa.mp3"}```

Update

```$ ./mp3_name_cleaner --root "/home/audiophile/Music/Hot MP3s/"```

```Copying /home/audiophile/Music/Hot MP3s//Source/Tal Bachman - She's So High-1999- Tal Bachman.mp3 to /home/audiophile/Music/Hot MP3s//Renamed/Tal Bachman - She's So High.mp3```


*NOTE: To build the executable try 'mix compile' first and then 'mix escript.build'*


Thank you!

Bibek Pandey 
:metal: