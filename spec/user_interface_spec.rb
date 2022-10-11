require 'user_interface'

RSpec.describe UserInterface do
  describe '#start_the_game' do
    it 'greets the players' do
      io = double(:io)
      unplaced_ships = [double(:ship_1, length: 2), double(:ship_2, length: 5)]
      player_1 = double(:player_1, rows: 10, cols: 10, unplaced_ships: unplaced_ships)
      player_2 = double(:player_2, rows: 10, cols: 10, unplaced_ships: unplaced_ships)

      interface = UserInterface.new(io, player_1, player_2)

      expect(io).to receive(:puts).with('--- START OF THE GAME ---')
      expect(io).to receive(:puts).with('Welcome to the game!')
      expect(io).to receive(:puts).with([
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
      ].join("\n"))
      expect(io).to receive(:puts).with('Set up your ships first.')

      interface.start_the_game
    end

    it "fails if board dimensions are not the same for both player (columns)" do
      io = double(:io)
      unplaced_ships = [double(:ship_1, length: 2)]
      player_1 = double(:player_1, rows: 10, cols: 10, unplaced_ships: unplaced_ships)
      player_2 = double(:player_2, rows: 10, cols: 5, unplaced_ships: unplaced_ships)

      expect {
        UserInterface.new(io, player_1, player_2)
      }.to raise_error "Board dimensions need to be the same for both players"
    end

    it "fails if board dimensions are not the same for both player (rows)" do
      io = double(:io)
      unplaced_ships = [double(:ship_1, length: 2)]
      player_1 = double(:player_1, rows: 5, cols: 10, unplaced_ships: unplaced_ships)
      player_2 = double(:player_2, rows: 10, cols: 10, unplaced_ships: unplaced_ships)

      expect {
        UserInterface.new(io, player_1, player_2)
      }.to raise_error "Board dimensions need to be the same for both players"
    end

    it "fails if both players don't have the same number of ships" do
      io = double(:io)
      unplaced_ships_1 = [double(:ship_1, length: 2), double(:ship_2, length: 5)]
      unplaced_ships_2 = [double(:ship_1, length: 2)]

      player_1 = double(:player_1, rows: 10, cols: 10, unplaced_ships: unplaced_ships_1)
      player_2 = double(:player_2, rows: 10, cols: 10, unplaced_ships: unplaced_ships_2)

      expect {
        UserInterface.new(io, player_1, player_2)
      }.to raise_error "Both players must have the same number of ships"
    end
  end

  describe '#allow_ships_placement' do
    it "it can place a ship on the board" do
      io = double(:io)
      unplaced_ships = [double(:ship_1, length: 2), double(:ship_2, length: 5)]
      player_1 = double(:player_1, player: "Player 1", rows: 10, cols: 10, unplaced_ships: unplaced_ships)
      player_2 = double(:player_2, player: "Player 2", rows: 10, cols: 10, unplaced_ships: unplaced_ships)

      interface = UserInterface.new(io, player_1, player_2)

      expect(io).to receive(:puts).with("Player 1 has these ships remaining: 2, 5")
      expect(io).to receive(:puts).with("Which do you wish to place?")
      expect(io).to receive(:gets).and_return('2')
      expect(io).to receive(:puts).with("Vertical or horizontal? [vh]")
      expect(io).to receive(:gets).and_return('h')
      expect(io).to receive(:puts).with('Which row?')
      expect(io).to receive(:gets).and_return('A')
      expect(io).to receive(:puts).with('Which column?')
      expect(io).to receive(:gets).and_return('1')
      expect(io).to receive(:puts).with('OK.')
      expect(player_1).to receive(:place_ship).with({
                                                      length: 2,
                                                      orientation: :horizontal,
                                                      row: 1,
                                                      col: 1
                                                    })
      expect(io).to receive(:puts).with('This is your board now:')
      allow(player_1).to receive(:ship_at?).and_return(false)
      allow(player_1).to receive(:ship_at?).with(1, 1).and_return(true)
      allow(player_1).to receive(:ship_at?).with(1, 2).and_return(true)
      expect(io).to receive(:puts).with([
        '  1 2 3 4 5 6 7 8 9 10',
        'A S . . . . . . . . .',
        'B S . . . . . . . . .',
        'C . . . . . . . . . .',
        'D . . . . . . . . . .',
        'E . . . . . . . . . .',
        'F . . . . . . . . . .',
        'G . . . . . . . . . .',
        'H . . . . . . . . . .',
        'I . . . . . . . . . .',
        'J . . . . . . . . . .'
      ].join("\n"))

      interface.allow_ships_placement(player_1)
    end
  end

  describe "#attack method" do
    it "can record a successful attack" do
      io = double(:io)
      unplaced_ships = [double(:ship_1, length: 2), double(:ship_2, length: 5)]
      player_1 = double(:player_1, rows: 10, cols: 10, unplaced_ships: unplaced_ships)
      player_2 = double(:player_2, rows: 10, cols: 10, unplaced_ships: unplaced_ships)

      allow(player_1).to receive(:hits).and_return([])
      allow(player_1).to receive(:miss).and_return([])

      expect(player_1).to receive(:player).and_return("Player 1")

      interface = UserInterface.new(io, player_1, player_2)

      expect(io).to receive(:puts).with("It's Player 1 turn")
      expect(io).to receive(:puts).with("Let's get your attack coordinates")
      expect(io).to receive(:puts).with("Which row?")
      expect(io).to receive(:gets).and_return("B")
      expect(io).to receive(:puts).with("Which column?")
      expect(io).to receive(:gets).and_return("2")
      expect(io).to receive(:puts).with("OK.")

      allow(player_2).to receive(:board).and_return([
                                                      [1, 2],
                                                      [2, 2]
                                                    ])

      expect(io).to receive(:puts).with("It's a hit!")
      expect(io).to receive(:puts).with([
        '  1 2 3 4 5 6 7 8 9 10',
        'A . . . . . . . . . .',
        'B . X . . . . . . . .',
        'C . . . . . . . . . .',
        'D . . . . . . . . . .',
        'E . . . . . . . . . .',
        'F . . . . . . . . . .',
        'G . . . . . . . . . .',
        'H . . . . . . . . . .',
        'I . . . . . . . . . .',
        'J . . . . . . . . . .'
      ].join("\n"))
      interface.attack(player_1, player_2)
    end

    it "can record an unsuccessful attack" do
      io = double(:io)
      unplaced_ships = [double(:ship_1, length: 2), double(:ship_2, length: 5)]
      player_1 = double(:player_1, rows: 10, cols: 10, unplaced_ships: unplaced_ships)
      player_2 = double(:player_2, rows: 10, cols: 10, unplaced_ships: unplaced_ships)

      allow(player_1).to receive(:hits).and_return([])
      allow(player_1).to receive(:miss).and_return([])

      expect(player_1).to receive(:player).and_return("Player 1")

      interface = UserInterface.new(io, player_1, player_2)

      expect(io).to receive(:puts).with("It's Player 1 turn")
      expect(io).to receive(:puts).with("Let's get your attack coordinates")
      expect(io).to receive(:puts).with("Which row?")
      expect(io).to receive(:gets).and_return("A")
      expect(io).to receive(:puts).with("Which column?")
      expect(io).to receive(:gets).and_return("1")
      expect(io).to receive(:puts).with("OK.")

      allow(player_2).to receive(:board).and_return([
                                                      [1, 2],
                                                      [2, 2]
                                                    ])

      expect(io).to receive(:puts).with("Water!")
      expect(io).to receive(:puts).with([
        '  1 2 3 4 5 6 7 8 9 10',
        'A O . . . . . . . . .',
        'B . . . . . . . . . .',
        'C . . . . . . . . . .',
        'D . . . . . . . . . .',
        'E . . . . . . . . . .',
        'F . . . . . . . . . .',
        'G . . . . . . . . . .',
        'H . . . . . . . . . .',
        'I . . . . . . . . . .',
        'J . . . . . . . . . .'
      ].join("\n"))
      interface.attack(player_1, player_2)
    end

    it "fails if the coordinates are not on the board" do
      io = double(:io)
      unplaced_ships = [double(:ship_1, length: 2), double(:ship_2, length: 5)]
      player_1 = double(:player_1, rows: 10, cols: 10, unplaced_ships: unplaced_ships)
      player_2 = double(:player_2, rows: 10, cols: 10, unplaced_ships: unplaced_ships)

      allow(player_1).to receive(:hits).and_return([])
      allow(player_1).to receive(:miss).and_return([])

      expect(player_1).to receive(:player).and_return("Player 1")

      interface = UserInterface.new(io, player_1, player_2)

      expect(io).to receive(:puts).with("It's Player 1 turn")
      expect(io).to receive(:puts).with("Let's get your attack coordinates")
      expect(io).to receive(:puts).with("Which row?")
      expect(io).to receive(:gets).and_return("K")
      expect(io).to receive(:puts).with("Which column?")
      expect(io).to receive(:gets).and_return("11")
      expect(io).to receive(:puts).with("OK.")

      expect { interface.attack(player_1, player_2) }.to raise_error "Coordinates are not on the board"
    end
  end
end
