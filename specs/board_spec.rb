require_relative 'spec_helper.rb'

def example
  empty_row = Array.new(8, " ")
  rows = []

  8.downto(1) do |number|
    rows << [number] + empty_row.clone
    rows << :separator
  end

  rows << ([" "] + Array("A".."H"))

  Terminal::Table.new :rows => rows
end

describe Board do
  describe "#new" do
    context "when given no input" do
      before(:each) do
        @board = Board.new
      end

      it "creates a new board" do
        expect(@board).to be_instance_of(Board)
      end

      it "has 2 Player objects in the players array" do
        expect(@board.players).to be_instance_of (Array)
        all_players = @board.players.all? {|player| player.is_a? Player}
        expect(all_players).to be true
      end
    end

    context "when given input" do
      context "and input is invalid type" do
        it "raises ArgumentError" do
          expect{Board.new("multiplayer")}.to raise_error(ArgumentError, "Incorrect input")
          expect{Board.new(5)}.to raise_error(ArgumentError, "Incorect input")
          expect{Board.new(['poop'])}.to raise_error(ArgumentError, "Incorect input")
        end
      end

      context "and input is invalid symbol" do
        it "raises ArgumentError" do
          expect{Board.new(:AI)}.to raise_error(ArgumentError, "AI is not acceptable input")
          expect{Board.new(:computer)}.to raise_error(ArgumentError, "computer is not acceptable input")
        end
      end

      context "and given valid input" do
        before(:each) do
          @board = Board.new(:multiplayer)
          @board2 = Board.new(:singleplayer)
        end

        it "creates new Board object" do
          expect(@board).to be_instance_of(Board)
          expect(@board2).to be_instance_of(Board)
        end

        context "and given :multiplayer" do
          it "creates a Board with 2 players in #players array" do
            expect(@board.players).to be_instance_of(Array)
            expect(@board.players.all? {|player| player.is_a? Player}).to be true
          end
        end

        context "and given :singleplayer" do
          it "creates a Board with 1 Player and 1 Artificial in #players array" do
            expect(@board2.players).to be_instance_of(Array)
            expect(@board2.players[0]).to be_instance_of(Player)
            expect(@board2.players[1]).to be_instance_of(Artificial)
          end
        end
      end
    end

    it "contains an empty board" do
      @board = Board.new
      expect(@board.table).to be_instance_of(Board)
      expect(@board.table).to eql(example())
    end
  end
end