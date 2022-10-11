class Game
  attr_reader :player, :unplaced_ships, :rows, :cols
  attr_accessor :board, :hits, :miss

  def initialize(player, rows, cols, unplaced_ships)
    @player = player
    @rows = rows
    @cols = cols
    @unplaced_ships = unplaced_ships
    @board = []
    @hits = []
    @miss = []
  end

  def unplaced_ships
    return @unplaced_ships
  end

  def rows
    return @rows
  end

  def cols
    return @cols
  end

  def place_ship(hash)
    length = hash.fetch(:length)
    orientation = hash.fetch(:orientation)
    x = hash.fetch(:col)
    y = hash.fetch(:row)
    ship_coordinates = []

    # Check ship is available for placement
    ship_to_be_placed = @unplaced_ships.find do |ship| ship.length == length end

    fail "The selected ship is not available" unless ship_to_be_placed != nil

    case orientation
    when :vertical
      # Check ship can vertically fit on the board
      fail "Coordinates are invalid" unless length <= (y..@rows).size
      # Generate coordinates for the ship
      length.times do
        ship_coordinates.push([x, y])
        y += 1
      end
      # Check overlapping
      overlapping = ship_coordinates.any? {|xy| @board.include?(xy)}
      if overlapping
        fail "Ship cannot overlap"
      else
        ship_coordinates.each {|xy| @board.push(xy)}
      end

    when :horizontal
      # Check if ship can horizontally fit on the board
      fail "Coordinates are invalid" unless length <= (x..@cols).size
      # Generate coordinates for the ship
      length.times do
        ship_coordinates.push([x, y])
        x += 1
      end
      # Check overlapping
      overlapping = ship_coordinates.any? {|xy| @board.include?(xy)}
      if overlapping
        fail "Ship cannot overlap"
      else
        ship_coordinates.each {|xy| @board.push(xy)}
      end
    end

    # Remove ship from unplaced_ships
    @unplaced_ships.delete_at(@unplaced_ships.index(ship_to_be_placed))

  end

  def ship_at?(x, y)
    return @board.any? do |xy| xy == [x, y] end
  end

end

class Ship
  attr_reader :name, :length

  def initialize(name, length)
    if name.empty? || !length.is_a?(Integer)
      raise 'Name or length are not valid'
    else
      @length = length
      @name = name
    end
  end
end
