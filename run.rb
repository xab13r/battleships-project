$LOAD_PATH << "lib"
require "game"
require "user_interface"

class TerminalIO
  def gets
    return Kernel.gets
  end

  def puts(message)
    Kernel.puts(message)
  end
end

io = TerminalIO.new

ship_1 = Ship.new("ship_1", 2)
ship_2 = Ship.new("ship_2", 5)

unplaced_ships = [
  ship_1,
  ship_2
]
player_1 = Game.new("Player 1", 10,10, unplaced_ships.clone)
player_2 = Game.new("Player 2", 10,10, unplaced_ships.clone)
user_interface = UserInterface.new(io, player_1, player_2)
user_interface.run
