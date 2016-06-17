defmodule MP3NameCleanerTest do
  use ExUnit.Case, async: true

  setup_all do
    IO.puts "MP3 Name Cleaner Test"
    :ok
  end

  test "simulate" do

    list =  [
      "MALO - SUAVECITO -LIVE AUDIENCE - 1972.mp3",
      "Toto - Africa-1982.mp3",
      "Spacehog - In the Meantime (Alt Version)-Resident Alien.mp3",
      "Ice Cube - You Know How We Do It-Lethal Injection.mp3",
      "Faith No More - Epic (1989)-The Real Thing.mp3",
      "Julieta Venegas - Lento-2003.mp3",
      "Guy - Let's Chill-1990.mp3",
      "Eric B. & Rakim - Juice (Know The Ledge)-1991.mp3",
      "America - A horse with no name (1971)-America.mp3",
      "HOWARD JONES - THINGS can only get BETTER-1985.mp3",
      "Fast Car by Tracy Chapman Studio Version-1988.mp3",
      "PRINCE   I Wanna Be Your Lover   Live Performance -Prince.mp3",
      "Toto - Rosanna-1982.mp3",
      "'Groove Theory' - TELL me [Album Version]-1995.mp3",
      "Mad Season - River Of Deceit-1995.mp3",
      "Alice In Chains - Would-1992.mp3",
      "Living Colour - Cult Of Personality-1988 Vivid.mp3",
      "Erykah Badu - Other Side Of The Game-1997-Baduizm.mp3",
      "SWV - I'm So Into You-1992-It's about time.mp3",
      "'Staying Alive' (1977) - Bee Gees-Disco.mp3"
    ]
    
    argv = ["--simulate", Enum.join(list, " ")] 

    map = argv |> MP3NameCleaner.main
    
    assert "Groove Theory - Tell Me.mp3" ==
      Map.get(map, "'Groove Theory' - TELL me [Album Version]-1995.mp3")

    assert "Staying Alive - Bee Gees.mp3" == 
      Map.get(map, "'Staying Alive' (1977) - Bee Gees-Disco.mp3")

    assert "Alice In Chains - Would.mp3" ==
      Map.get(map, "Alice In Chains - Would-1992.mp3")

    assert "America - A Horse With No Name.mp3" == 
      Map.get(map, "America - A horse with no name (1971)-America.mp3")

    assert "Eric B. & Rakim - Juice.mp3" == 
      Map.get(map, "Eric B. & Rakim - Juice (Know The Ledge)-1991.mp3")

    assert "Erykah Badu - Other Side Of The Game.mp3" == 
      Map.get(map, "Erykah Badu - Other Side Of The Game-1997-Baduizm.mp3")

    assert "Faith No More - Epic.mp3" == 
      Map.get(map, "Faith No More - Epic (1989)-The Real Thing.mp3")

    assert "Fast Car By Tracy Chapman Studio Version.mp3" == 
      Map.get(map, "Fast Car by Tracy Chapman Studio Version-1988.mp3")

    assert "Guy - Let's Chill.mp3" == 
      Map.get(map, "Guy - Let's Chill-1990.mp3")

    assert "Howard Jones - Things Can Only Get Better.mp3" == 
      Map.get(map, "HOWARD JONES - THINGS can only get BETTER-1985.mp3")

    assert "Ice Cube - You Know How We Do It.mp3" == 
      Map.get(map, "Ice Cube - You Know How We Do It-Lethal Injection.mp3")

    assert "Julieta Venegas - Lento.mp3" == 
      Map.get(map, "Julieta Venegas - Lento-2003.mp3")

    assert "Living Colour - Cult Of Personality.mp3" == 
      Map.get(map, "Living Colour - Cult Of Personality-1988 Vivid.mp3")

    assert "Mad Season - River Of Deceit.mp3" == 
      Map.get(map, "Mad Season - River Of Deceit-1995.mp3")

    assert "Prince - I Wanna Be Your Lover.mp3" == 
      Map.get(map, "PRINCE   I Wanna Be Your Lover   Live Performance -Prince.mp3")

    assert "SWV - I'm So Into You.mp3" == 
      Map.get(map, "SWV - I'm So Into You-1992-It's about time.mp3")

    assert "Spacehog - In The Meantime.mp3" == 
      Map.get(map, "Spacehog - In the Meantime (Alt Version)-Resident Alien.mp3")

    assert "Toto - Africa.mp3" == 
      Map.get(map, "Toto - Africa-1982.mp3")
              
    assert "Toto - Rosanna.mp3" == 
      Map.get(map, "Toto - Rosanna-1982.mp3")

    assert "Malo - Suavecito.mp3" == 
      Map.get(map, "MALO - SUAVECITO -LIVE AUDIENCE - 1972.mp3")    
  end

#  test "rename" do
#    argv = ["--root", "/home/audiophile/Music/Hot MP3s/"]
#     
#    argv |> MP3NameCleaner.main
#  end

end
