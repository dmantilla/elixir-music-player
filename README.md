# elixir-music-player

Aren't you tired of launching iTunes to play your huge library of songs? Well, I was and decided to build this command line app in Elixir to collect all songs in my Music folder and play them randomly.

For now it can only _play_, _**s**kip_ and _e**x**it_. Feel free to improve the code.

# Playing music

## Elixir Console

You can do this the first time. It will compile and play the music.

    $ elixir -r 'jukebox.ex' -e 'Jukebox.rock("/Users/dan/Music")'

The next time you can just run the code with:

    $ elixir -e 'Jukebox.rock("/Users/dan/Music")'
