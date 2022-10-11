class UserInterface
  def initialize(io, player_1, player_2)
    @io = io
    @player_1 = player_1
    @player_2 = player_2
    @coordinates = { "A": 1, "B": 2, "C": 3, "D": 4, "E": 5, "F": 6, "G": 7, "H": 8, "I": 9, "J": 10, "K": 11, "L": 12,
                     "M": 13, "N": 14, "O": 15, "P": 16, "Q": 17, "R": 18, "S": 19, "T": 20, "U": 21, "V": 22, "W": 23, "X": 24, "Y": 25, "Z": 26, }

    # Check that board dimensions are the same for both players
    if @player_1.cols != @player_2.cols || @player_1.rows != @player_2.rows
      fail "Board dimensions need to be the same for both players"
    end

    # Check that both players have the same amount of ship to place
    fail "Both players must have the same number of ships" unless @player_1.unplaced_ships.length == @player_2.unplaced_ships.length

    @max_hits = player_1.unplaced_ships.sum { |s| s.length }
  end

  def run
    start_the_game
    while !@player_1.unplaced_ships.empty? do
      begin
        allow_ships_placement(@player_1)
      rescue
        show "[!] Some inputs were not correct - Try again."
      end
    end

    while !@player_2.unplaced_ships.empty? do
      begin
        allow_ships_placement(@player_2)
      rescue
        show "[!] Some inputs were not correct - Try again."
      end
    end
    # p "[*] PLAYER TWO SETUP"
    show "[*] Let's start the game!"

    counter = 1
    while @player_1.hits.length < @max_hits && @player_2.hits.length < @max_hits
      show "[!] Turn #{counter}"
      begin
        attack(@player_1, @player_2)
      rescue
        "[!] Coordinates were not valid - Try again."
      end
      begin
        attack(@player_2, @player_1)
      rescue
        "[!] Coordinates were not valid - Try again."
      end
      counter += 1
    end
    if @player_1.hits.length == @max_hits
      show "#{@player_1.player} wins!"
    elsif @player_2.hits.length == @max_hits
      show "#{@player_2.player} wins!"
    end

    show "--- END OF GAME ---"
  end

  def start_the_game
    show "--- START OF THE GAME ---"
    show "Welcome to the game!"
    show [
      '  1 2 3 4 5 6 7 8 9 10',
      'A . . . . . . . . . .',
      'B . . . . . . . . . .',
      'C . . . . . . . . . .',
      'D . . . . . . . . . .',
      'E . . . . . . . . . .',
      'F . . . . . . . . . .',
      'G . . . . . . . . . .',
      'H . . . . . . . . . .',
      'I . . . . . . . . . .',
      'J . . . . . . . . . .'
    ].join("\n")
    show "Set up your ships first."
  end

  def allow_ships_placement(player)
    show "#{player.player} has these ships remaining: #{ships_unplaced_message(player)}"
    ship_length = prompt "Which do you wish to place?"
    ship_orientation = prompt "Vertical or horizontal? [vh]"
    ship_row = prompt "Which row?"
    ship_col = prompt "Which column?"
    show "OK."
    placement_hash = {
      length: ship_length.to_i,
      orientation: { "v" => :vertical, "h" => :horizontal }.fetch(ship_orientation),
      row: @coordinates[ship_row.upcase.to_sym],
      col: ship_col.to_i
    }
    player.place_ship(placement_hash)
    show "This is your board now:"
    show format_board(player)
  end

  def attack(attacker, defender)
    show "It's #{attacker.player} turn"
    show "Let's get your attack coordinates"
    row = prompt "Which row?"
    col = prompt "Which column?"
    show "OK."
    x = col.to_i
    y = @coordinates[row.upcase.to_sym]

    # Check if coordinates are on the board
    fail "Coordinates are not on the board" unless (1..defender.cols).include?(x) && (1..defender.rows).include?(y)

    if defender.board.include?([x, y])
      attacker.hits.push([x, y])
      show "It's a hit!"
    elsif attacker.miss.push([x, y])
      show "Water!"
    end
    show format_attack_board(attacker)
  end

  private

  def show(message)
    @io.puts(message)
  end

  def prompt(message)
    @io.puts(message)
    return @io.gets.chomp
  end

  def ships_unplaced_message(player)
    return player.unplaced_ships.map do |ship|
      "#{ship.length}"
    end.join(", ")
  end

  def format_board(player)
    first_row = (1..player.cols).map do |n| n.to_s end
    first_col = (1..player.rows).map do |n| @coordinates.key(n) end

    result = (1..player.rows).map do |y|
      (1..player.cols).map do |x|
        next "S" if player.ship_at?(x, y)

        next "."
      end
    end

    (player.rows).times do |i|
      result[i].insert(0, @coordinates.key(i + 1).to_s)
    end
    result.insert(0, first_row)
    result[0].insert(0, " ")
    return result.map do |y|
             y.map do |x|
               x
             end.join(" ")
           end.join("\n")
  end

  def format_attack_board(player)
    first_row = (1..player.cols).map do |n| n.to_s end
    first_col = (1..player.rows).map do |n| @coordinates.key(n) end

    result = (1..player.rows).map do |y|
      (1..player.cols).map do |x|
        next "X" if player.hits.include?([x, y])
        next "O" if player.miss.include?([x, y])

        next "."
      end
    end

    (player.rows).times do |i|
      result[i].insert(0, @coordinates.key(i + 1).to_s)
    end
    result.insert(0, first_row)
    result[0].insert(0, " ")
    return result.map do |y|
             y.map do |x|
               x
             end.join(" ")
           end.join("\n")
  end
end
