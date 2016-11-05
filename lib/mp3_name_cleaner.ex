defmodule MP3NameCleaner do

  @moduledoc """
  Cleans up mp3 file names given the assumptions:
  1) the song info types e.g. Artist Name, Song Title, Album Name, Year 
  are delimited by a hyphen

  2) the Artist names and Song names are generally first.
  
  Does a non-destructive update copy of the original file set 
  with cleaned up names
  
  Provides support for title-casing, whitespace trimming, 
  extraneous info removal e.g. text in parens or brackets or curly braces
  
  For example: 
  
  The names to the left of the arrow are uncleaned
  Those on the right are cleaned names.
  
  MALO - SUAVECITO -LIVE AUDIENCE - 1972.mp3 => Malo - Suavecito.mp3
  Toto - Africa-1982.mp3 => Toto - Africa.mp3
  Spacehog - In the Meantime (A)-Resident Alien.mp3 => Spacehog - In The Meantime.mp3
  'Groove Theory' - TELL me [Album Version]-1995.mp3 => Groove Theory - Tell Me.mp3
  SWV - I'm So Into You-1992-It's about time.mp3 => SWV - I'm So Into You.mp3  
  """

  @songs_source_dir_path "/Source/"
  @songs_dest_dir_path "/Renamed/"

  @log_file "Mapping Log.txt"

  # Unstandardized song info delimiters used
  @supposed_delims ["~", "..", " _ ", "   "]

  @delim "-"
  @new_delim " - "

  # This really is just a sampling, could easily be a large db
  @artist_abbr ["LL", "SWV", "ABBA", "P.M.", "II"]

  def main(args) do
    case input(args) do
      {} -> raise "No input data, Abort"
      {:update, list, root_dir} -> run(:update, list, root_dir)      
      {:simulate, list} -> run(:simulate, list)
    end
  end

  def run(:update, list, root_dir) when is_list(list) and is_binary(root_dir) do
    list |> setup |> log(root_dir) |> rename(root_dir)
  end

  def run(:simulate, list) when is_list(list) do
    list |> setup |> IO.inspect
  end

  def input(args) do
    {parsed, _argv, _errors}  = OptionParser.parse(args, 
      [
        strict: [
          root: :string, # --root, string only
          simulate: :string, # --simulate, string only
          help: :boolean # --help, boolean only
        ],
    ])

    #IO.puts "parsed args are: #{inspect temp}"

    if [] == parsed or {:ok, true} == Keyword.fetch(parsed, :help) do
        IO.puts "Specify args as such: --root_path <root_dir> or -simulate <mp3 list>"
        System.halt(0)
    end

    params1 = 
      case Keyword.fetch(parsed, :simulate) do
        {:ok, value} ->
          # OptionParser doesn't support lists as params,
          # So we split a long String with multiples mp3 values
          
          # Split returns a list, 
          # trim the last element which is content w/o the mp3 suffix
          # for each list item add suffix .mp3
          list = 
            value 
            |> String.split(".mp3", trim: true)
            |> Enum.map(&String.strip(&1))
            |> Enum.map(&(&1 <> ".mp3"))
          
          {:simulate, list}
        _ -> []
      end
    
    params2 = 
      case Keyword.fetch(parsed, :root) do
        {:ok, root_dir} ->
          case File.dir?(root_dir) do
            true -> 
              song_path = "#{root_dir}" <> @songs_source_dir_path
              
              unless File.dir?(song_path) do 
                raise "Source directory: #{song_path} not valid"
              end
              
              {:ok, list} = File.ls song_path
              
              {:update, list, root_dir}            
            false -> 
              raise ":root_path value does not exist as a dir, please retry"
          end
        _ -> []
      end

    vector = [params1] ++ [params2]
    
    # If all the vector list elements are empty lists, error
    
    # Else filter the vector to only those are that aren't not empty
    # And choose the first one (precedence is simulate then root if both specified)
    
    with false <- Enum.all?(vector, fn x -> x == [] end) do
      
      vector = Enum.reject(vector, fn x -> x == [] end)
      
      # Choose the first secrets vector
      params = List.first(vector)
      
      params
    else
      _ -> raise "user must specify either simulate or path value"
    end

  end
  
  
  def setup(list) when is_list(list) do
    
    # Given the list of mp3 song titles
    # ["The Jets --Crush on You (1986)- Live.mp3",
    # "Big Daddy Kane ... Smooth Operator- Full Remix - 1989.mp3",
    # "SWV- You're The One- Greatest Hits - R&B.mp3"]
    
    # 1) Duplicate each list song name value and then replacing ~, .., _ with -, 
    # So we can keep the original song name key 'k' for later, 
    # While transforming the value 'v' many successive times

    # {"Brownstone -If you love me-Soul-1995.mp3", 
    # "Brownstone -If you love me-Soul-1995.mp3"},

    # NOTE: This is a long series of transforms delineated by the |> operator
    #       rather than separate these into separate functions, I am including
    #       them in a single function for readability

    stream = 
      list 
      |> Stream.map(&({&1, &1})) 
      |> Stream.map(fn {k, v} -> {k, String.replace(v, @supposed_delims, @delim)} end)

    # DROP SINGLE QUOTES
    # 2a) Replace text surrounded by single quotes with just the extracted text, 
    # Provided the first single quote is preceded by a space or at start
    # Preserve the key-value relationship {k,v}, with the new transformed v
      |> Stream.map(fn {k, v} -> {k, String.replace(v, ~r/[ ]\'(.*)\'/, " \\g{1}")} end)
      |> Stream.map(fn {k, v} -> {k, String.replace(v, ~r/^\'(.*)\'/, " \\g{1}")} end)

    # REMOVE SQUARE BRACKETS AND EMBEDDED TEXT
    # 2b) For each song string list element, 
    # replace anything inside square brackets with ""
    # "Gloria Estefan   Here We Are [Instrumental]" to 
    # "Gloria Estefan   Here We Are ",
    # Preserve the key-value relationship {k,v}, with the new transformed v
      |> Stream.map(fn {k,v} -> {k, String.replace(v, ~r/\[.*\]/, "")} end)

    # REMOVE PARENTHESES AND/OR CURLY BRACES AND EMBEDDED TEXT
    # 2c) For each song string list element, 
    # replace anything inside parens () or {} curly braces with ""
    # "Matchbox Twenty ~ 3AM (Live)" to "Matchbox Twenty ~ 3AM ",
    # Preserve the key-value relationship {k,v}, with the new transformed v
      |> Stream.map(fn {k,v} -> {k, String.replace(v, ~r/\(.*\)/, "")} end)
      |> Stream.map(fn {k,v} -> {k, String.replace(v, ~r/\{.*\}/, "")} end)

    # SPLIT INTO SONG INFO TOKENS
    # 3) Break down each value element into Artist, Song, and Extra by "-" 
    # or "   " delimiters
    # ["P.M. Dawn ", " Set Adrift On Memory Bliss", "128.mp3"]
    # Preserve the key-value relationship {k,v}, with the new transformed v
      |> Stream.map(fn {k,v} -> {k, String.split(v, @delim, parts: 3)} end)

    # DELETE LAST TOKEN
    # 4) In the value list, delete the last extra token "XXXX.mp3"
    # Preserve the key-value relationship {k,v}, with the new transformed v
      |> Stream.map(fn {k,v} -> 
        true = List.last(v) |> String.ends_with?(".mp3")
        v2 = List.delete_at(v, -1)
        {k, v2}
      end)

    # TRIM SONG INFO TOKENS & MERGE
    # 5a) For each of the song tokens in the value, trim the tokens
    # ["P.M. Dawn", "Set Adrift On Memory Bliss [Full MIX]"]
    # ["Matchbox Twenty ", " 3AM [Official MIX]"]

    # 5b) Then, merge the tokens with a " - " delimiter
    # "P.M. Dawn - "Set Adrift On Memory Bliss [Full MIX]"
    # "Matchbox Twenty - 3AM [Official MIX]",
    # Preserve the key-value relationship {k,v}, with the new transformed v
      |> Stream.map(fn {k,v} -> 
        v2 = Enum.map(v, &String.strip(&1)) |> Enum.join(@new_delim)
        {k, v2}
      end)

    # TITLECASE ALL WORDS
    # 6) For each info token e.g. Artist, Song Name info, title case all words
    # to eliminate cap issues

    # Split token into words based on whitespace, then Titlecase words
    # Then join them back into their respective info tokens

    # Preserve the key-value relationship {k,v}, with the new transformed v
      |> Stream.map(fn {k,v} ->

        v2 = 
          String.split(v) 
          |> Enum.map(fn w ->
             # If word isn't one of these exceptions, titlecase
               if w in @artist_abbr do w else String.capitalize(w) end
             end) 
          |> Enum.join(" ")
        
        {k, v2}
      end)

    # TRIM
    # 7) Trim white spaces
    # " Gloria Estefan - Here We Are " -> "Gloria Estefan - Here We Are",
    # Preserve the key-value relationship {k,v}, with the new transformed v
      |> Stream.map(fn {k,v} -> {k, String.strip(v)} end)

    # APPEND .mp3
    # 8) Append .mp3 suffix to string
    # Preserve the key-value relationship {k,v}, with the new transformed v  
      |> Stream.map(fn {k,v} -> {k, v <> ".mp3"} end)
    

    # Take the stream we have created and run a greedy reduce on them
    # to perform the above transformations and then lastly to store in Map

    # NOTE: The stream computation is composable as each k-v pair is worked on 
    # one at a time

    # Put k,v into a map
    map = stream |> Enum.reduce(%{}, fn {k,v}, acc -> Map.put(acc, k, v) end)
    
    map
  end

  def log(%{} = map, root_dir) when is_binary(root_dir) do

    log_path = root_dir <> @log_file

    if File.exists?(log_path), do: :ok = File.rm(log_path)

    {:ok, fd} = File.open(log_path, [:append])

    Stream.each(map, fn {k,v} -> 
      IO.puts(fd, "#{k}" <> " => " <> "#{v}")
    end) |> Stream.run

    :ok = File.close(fd)

    # return map
    map
  end

  def rename(%{} = map, root_dir) when is_binary(root_dir) do
    # By using File.cp! we do a non-destructive update of original

    source_dir = root_dir <> @songs_source_dir_path
    dest_dir = root_dir <> @songs_dest_dir_path

    case File.dir?(source_dir) do
      false -> 
        raise "source directory: #{source_dir} not found"
      true ->
        case File.dir?(dest_dir) do
          false -> raise "destination dir: #{dest_dir} not found"
          true -> ""
        end
    end

    Stream.map(map, fn {k,v} ->
      source = source_dir <> k
      dest = dest_dir <> v  
      IO.puts "Copying #{source} to #{dest}"
      File.cp! source, dest
    end)
    |> Stream.run
    
  end

end
