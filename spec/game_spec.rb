require 'game'

RSpec.describe Game do
  context "it constructs the class" do
    it "can returns player's name, rows, and columns" do
      unplaced_ships = double(:unplaced_ship)
      game = Game.new("Player", 10, 10, unplaced_ships)
      expect(game.player).to eq "Player"
      expect(game.rows).to eq 10
      expect(game.cols).to eq 10
    end
  end

  describe "#place_ship" do
    it "fails if the ship is not available for placement" do
      ship_1 = double(:ship, length: 3)
      unplaced_ships = [ship_1]
      game = Game.new("Player", 10, 10, unplaced_ships)
      values = {
        length: 5,
        orientation: :vertical,
        row: 2,
        col: 2
      }
      expect { game.place_ship(values) }.to raise_error "The selected ship is not available"
    end

    it "can place a ship vertically" do
      ship_1 = double(:ship, length: 3)
      unplaced_ships = [ship_1]
      game = Game.new("Player", 10, 10, unplaced_ships)

      game.place_ship({
                        length: 3,
                        orientation: :vertical,
                        row: 2,
                        col: 2
                      })
      result = game.board
      expect(result).to eq [[2, 2], [2, 3], [2, 4]]
      expect(game.ship_at?(2, 2)).to eq true
      expect(game.ship_at?(3, 1)).to eq false
    end

    it "can place a ship horizontally" do
      ship_1 = double(:ship, length: 5)
      unplaced_ships = [ship_1]
      game = Game.new("Player", 10, 10, unplaced_ships)
      game.place_ship({
                        length: 5,
                        orientation: :horizontal,
                        row: 1,
                        col: 1
                      })
      result = game.board
      expect(result).to eq [[1, 1], [2, 1], [3, 1], [4, 1], [5, 1]]
    end

    it "fails if ships are outside of the board" do
      ship_1 = double(:ship, length: 3)
      ship_2 = double(:ship, length: 2)
      unplaced_ships = [ship_1, ship_2]
      game = Game.new("Player", 5, 5, unplaced_ships)
      values = {
        length: 3,
        orientation: :vertical,
        row: 10,
        col: 10
      }
      expect { game.place_ship(values) }.to raise_error "Coordinates are invalid"
    end

    it "removes a ship from unplaced_ship after placement" do
      ship_1 = double(:ship_1, length: 3)
      ship_2 = double(:ship_2, length: 2)
      unplaced_ships = [ship_1, ship_2]
      game = Game.new("Player", 10, 10, unplaced_ships)
      game.place_ship(length: 3, orientation: :vertical, row: 1, col: 1)
      expect(game.unplaced_ships).to eq [ship_2]
    end

    it "fails if ships will overlap horizontally" do
      ship_1 = double(:ship_1, length: 3)
      ship_2 = double(:ship_2, length: 2)
      unplaced_ships = [ship_1, ship_2]
      game = Game.new("Player", 10, 10, unplaced_ships)
      game.place_ship(length: 3, orientation: :vertical, row: 1, col: 2)
      values = {
        length: 2,
        orientation: :horizontal,
        row: 1,
        col: 1
      }
      expect { game.place_ship(values) }.to raise_error "Ship cannot overlap"
    end

    it "fails if ships will overlap vertically" do
      ship_1 = double(:ship_1, length: 3)
      ship_2 = double(:ship_2, length: 2)
      unplaced_ships = [ship_1, ship_2]
      game = Game.new("Player", 10, 10, unplaced_ships)
      game.place_ship(length: 3, orientation: :horizontal, row: 2, col: 2)
      values = {
        length: 2,
        orientation: :vertical,
        row: 1,
        col: 3
      }
      expect { game.place_ship(values) }.to raise_error "Ship cannot overlap"
    end
  end

  describe "#ship_at?" do
    it "returns true if there is a ship at given coordinates" do
      ship_1 = double(:ship_1, length: 2)
      ship_2 = double(:ship_2, length: 5)
      unplaced_ships = [ship_1, ship_2]
      game = Game.new("Player", 10, 10, unplaced_ships)
      game.place_ship({ length: 5, orientation: :vertical, row: 1, col: 2 })
      expect(game.ship_at?(2, 4)).to eq true
      expect(game.ship_at?(1, 1)).to eq false
    end
  end
end
