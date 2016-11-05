# MP3NameCleaner

 Many aeons ago I was the Content Ingestion Manager for the inaugural AmazonMP3 service
 setting up the music service with its first 2 million tracks over the course of a year.
 I worked with digital music aggregators (e.g. CDBaby, Ioda, Naxos), 
 the big labels (e.g. Warner, Sony) to get this done.

 To this day, I still use MP3s!  Here's a little side script I wrote over a few days 
 at a local Starbucks coffee shop.

## Description

 Straightforward script written in Elixir, using Streams and Enums

 Cleans up mp3 file names given the assumptions:
 * The song info types e.g. Artist Name, Song Title, Album Name, Year are delimited by a hyphen
 * The Artist names and Song names are generally first.
 * The file contains a .mp3 suffix

 Does a non-destructive update copy of the original file set 
 with cleaned up names

 Provides support for title-casing, whitespace trimming, 
 extraneous info removal e.g. text in parens or brackets or curly braces

 For example: 

 The names to the left of the arrow are uncleaned
 Those on the right are cleaned names.

```
 MALO - SUAVECITO -LIVE AUDIENCE - 1972.mp3 => Malo - Suavecito.mp3
 Toto - Africa-1982.mp3 => Toto - Africa.mp3
 Spacehog - In the Meantime (A)-Resident Alien.mp3 => Spacehog - In The Meantime.mp3
 'Groove Theory' - TELL me [Album Version]-1995.mp3 => Groove Theory - Tell Me.mp3
 SWV - I'm So Into You-1992-It's about time.mp3 => SWV - I'm So Into You.mp3
```

# USAGE: 

Two modes: 
1. Simulation - test it out
2. Update -  performs actual non-destructive update - requires specifying root directory. 
   Also requires creating a directory called "Source" under the root dir as well as a 
   directory called "Renamed".  Please put the files to be cleaned under the source directory

1.
```$ ./mp3_name_cleaner --simulate "MALO - SUAVECITO -LIVE AUDIENCE - 1972.mp3 Toto - Africa-1982.mp3"
%{"MALO - SUAVECITO -LIVE AUDIENCE - 1972.mp3" => "Malo - Suavecito.mp3",
  "Toto - Africa-1982.mp3" => "Toto - Africa.mp3"}```

2.
```$ ./mp3_name_cleaner --root "/home/audiophile/Music/Hot MP3s/"
Copying /home/audiophile/Music/Hot MP3s//Source/Tal Bachman - She's So High-1999- Tal Bachman.mp3 to /home/audiophile/Music/Hot MP3s//Renamed/Tal Bachman - She's So High.mp3```

*NOTE: To build the executable try 'mix compile' first and then 'mix escript.build'*