defmodule Jukebox do
  def rock(path // ".") do
    player = spawn(Jukebox.Player, :serve, [])
    console = spawn(Jukebox.Console, :run, [])
    
    console <- {:wait, self}
    
    entries(path)
    |> shuffle
    |> reproduce(player, console)
  end
  
  def entries(path) do
    if path == "." do
      {:ok, entries_path} = File.cwd
    else
      entries_path = path
    end
    list = _entries(File.ls(entries_path), entries_path, [])
    IO.puts "#{length(list)} songs found.\n"
    list
  end

  def reproduce([], _player, _console), do: nil
  def reproduce([entry | queue], player, console) do
    [path, name] = entry
    track = full_path(path, name)
    player <- {:play, track, self}
    receive do
      {:song_played} -> 
        reproduce(queue, player, console)
        
      {:waiting_for_input} -> 
        console <- {:wait, self}
        reproduce(queue, player, console)
        
      {:exit} ->
        IO.puts "Bye."
        :timer.sleep 500
    end
  end
  
  def shuffle(songs) do
    :random.seed :erlang.now
    Enum.shuffle(songs)
  end
  
  def full_path(path, entry), do: "#{path}/#{entry}"
  
  #----------------------------------------------------
  
  defp _entries( { :ok, list }, path, selection ) do
    _entries list, path, selection
  end
  
  defp _entries( {:error, _error_type }, _path, selection), do: selection
  
  defp _entries([], _path, selection), do: selection
  
  defp _entries([entry | rest], path, selection) do
    entry_path = full_path(path, entry)
    cond do
      File.dir?(entry_path) ->
        new_selection = _entries(File.ls(entry_path), entry_path, selection)
        _entries rest, path, new_selection
      Regex.run(%r/\.m4a$|\.mp3$/, entry) == nil ->
        _entries rest, path, selection
      true ->
        _entries rest, path, [[path, entry] | selection]
    end
  end

  defmodule Console do
    def kill_sys_cmd do
      pid = System.cmd "pgrep afplay"
      System.cmd "kill -9 #{pid}"
    end

    def run do
      receive do
        {:wait, jukebox} -> 
          input = IO.gets(:stdio, "> ")
          process(input, jukebox)
          run
      end
    end
    
    def process(input, jukebox) do
      String.strip(input, 10)
      |>
      case do
        "s"     -> skip(jukebox)
        "x"     -> stop(jukebox)
        command -> help_with(command, jukebox)
      end
    end
    
    def skip(jukebox) do
      kill_sys_cmd
      IO.puts " skipping ..."
      jukebox <- {:waiting_for_input}
    end
    
    def stop(jukebox) do
      kill_sys_cmd
      jukebox <- {:exit}
    end
    
    def help_with(command, jukebox) do
      IO.puts """
        Couldn't understand [#{command}]. 
        Available commands are:
        
        s : skip current song
        x : exit
      """
      jukebox <- {:waiting_for_input}
    end
  end
  
  defmodule Player do
    def serve do
      receive do
        {:play, track, jukebox} ->
          IO.puts "Playing #{track}"
          System.cmd "afplay \"#{track}\""
          jukebox <- {:song_played}
          serve
      end
    end
  end
end
