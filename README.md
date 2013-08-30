# elixir-music-player

First 'serious' small project in Elixir

# Playing music

## Elixir Console

You can do this the first time. It will compile and play the music.

    $ elixir -r 'jukebox.ex' -e 'Jukebox.rock("/Users/dan/Music")'

The next time you can just run the code with:

    $ elixir -e 'Jukebox.rock("/Users/dan/Music")'
