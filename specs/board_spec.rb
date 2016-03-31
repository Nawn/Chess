require_relative 'spec_helper.rb'

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
          expect{Board.new(5)}.to raise_error(ArgumentError, "Incorrect input")
          expect{Board.new(['poop'])}.to raise_error(ArgumentError, "Incorrect input")
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

    it "has rows populated with Pieces in first 2 and last 2 rows" do
      @board = Board.new

      expect(@board.rows).to be_instance_of(Array)

      pieces = @board.rows[0..1].all? {|array| array.all? {|piece| piece.is_a? Piece}}
      back_pieces = @board.rows[-1..-2].all? {|array| array.all? {|piece| piece.is_a? Piece}}
      mid_spaces = @board.rows[2..5].all? {|array| array.all? {|space| space == " "}}

      expect(pieces).to be true
      expect(back_pieces).to be true
      expect(mid_spaces).to be true
    end

    it "Has rows filled with Rooks, Knights, Bishops, King and Queen" do
      @board = Board.new
      expect(@board.rows).to be_instance_of(Array)

      expect(@board.rows[0][0]).to be_instance_of(Rook)
      expect(@board.rows[0][1]).to be_instance_of(Knight)
      expect(@board.rows[0][2]).to be_instance_of(Bishop)
      expect(@board.rows[0][4]).to be_instance_of(King)
      expect(@board.rows[0][3]).to be_instance_of(Queen)
      all_pawn = @board.rows[1].all? {|pawn| pawn.is_a? Pawn}
      expect(all_pawn).to be true
    end
  end
end