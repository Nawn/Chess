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
      expect(@board.rows[0][3]).to be_instance_of(Queen)
      expect(@board.rows[0][4]).to be_instance_of(King)
      all_pawn = @board.rows[1].all? {|pawn| pawn.is_a? Pawn}
      expect(all_pawn).to be true
    end
  end

  describe "#view" do
    before(:each) do
      @board = Board.new
    end

    it "does not take input" do
      expect{@board.view(:white)}.to raise_error(ArgumentError)
    end

    it "returns a symbol" do
      expect(@board.view).to be_instance_of(Symbol)
    end

    it "is initialized as :white" do
      expect(@board.view).to eql(:white)
    end

    it "can be read" do
      expect{@board.view}.not_to raise_error
      expect{@board.view = :black}.to raise_error(NoMethodError)
    end
  end

  describe "#flip" do
    before(:each) do
      @board = Board.new
    end

    context "when given no input" do
      it "flips the board" do
        expect(@board.rows[0][0].team_color).to eql(:black)
        expect(@board.view).to eql(:white)
        @board.flip
        expect(@board.rows[0][0].team_color).to eql(:white)
        expect(@board.view).to eql(:black)
        @board.flip
        expect(@board.rows[0][0].team_color).to eql(:black)
        expect(@board.view).to eql(:white)
      end
    end

    context "when given input" do
      context "and input is invalid data type" do
        it "raises ArgumentError" do
          expect{@board.flip("white")}.to raise_error(ArgumentError, "Input must be symbol")
          expect{@board.flip(5)}.to raise_error(ArgumentError, "Input must be symbol")
          expect{@board.flip([:white])}.to raise_error(ArgumentError, "Input must be symbol")
        end
      end

      context "and input_symbol does not exist" do
        it "raises StandardError" do
          expect{@board.flip(:yellow)}.to raise_error(StandardError, "Input must be :white, or :black")
          expect{@board.flip(:blue)}.to raise_error(StandardError, "Input must be :white, or :black")
        end
      end

      context "if input is acceptable" do
        context "and the view is set to the input already" do
          it "will not flip the board" do
            expect(@board.rows[0][0].team_color).to eql(:black)
            expect(@board.view).to eql(:white)
            @board.flip(:white)
            expect(@board.rows[0][0].team_color).to eql(:black)
            expect(@board.view).to eql(:white)
          end
        end

        context "and the board is not set to the color input" do
          it "changes the board view to given symbol" do
            expect(@board.view).to eql(:white)
            @board.flip(:black)
            expect(@board.view).to eql(:black)
            @board.flip(:white)
            expect(@board.view).to eql(:white)
          end

          it "flips the board" do
            expect(@board.rows[0][0].team_color).to eql(:black)
            @board.flip(:black)
            expect(@board.rows[0][0].team_color).to eql(:white)
            @board.flip(:white)
            expect(@board.rows[0][0].team_color).to eql(:black)
          end
        end
      end
    end
  end

  describe "#mark" do
    before(:each) do
      @board = Board.new
    end

    context "when given no input" do
      it "raises ArgumentError" do
        expect{@board.mark()}.to raise_error(ArgumentError)
      end
    end

    context "when given input" do
      context "if input is not valid" do
        context "such as incorrect data types" do
          it "raises ArgumentError" do
            expect{@board.mark(23)}.to raise_error(ArgumentError, "Input must be String")
            expect{@board.mark(["A2"])}.to raise_error(ArgumentError, "Input must be String")
          end
        end

        context "such as invalid String" do
          it "raises ArgumentError" do
            expect{@board.mark("poop")}.to raise_error(ArgumentError, "Input incorrect. Example: C4, B2, A3, etc.")
            expect{@board.mark("4C")}.to raise_error(ArgumentError, "Input incorrect. Example: C4, B2, A3, etc.")
            expect{@board.mark("sure buddy")}.to raise_error(ArgumentError, "Input incorrect. Example: C4, B2, A3, etc.")
            expect{@board.mark("C9")}.to raise_error(ArgumentError, "Input incorrect. Example: C4, B2, A3, etc.")
          end
        end
      end
      
      context "if input is valid" do
        context "if space is empty" do
          it "marks spot with an X" do
            expect(@board.rows[4][3]).to eql(" ")
            @board.mark("D4")
            expect(@board.rows[4][3]).to eql(:X)
          end
        end

        context "if space is enemy player" do
          it "sets the space to a String" do
            expect(@board.rows[0][2]).not_to be_instance_of(String)
            @board.mark("C8")
            expect(@board.rows[0][2]).to be_instance_of(String)
          end

          context "when queen" do          
            it "sets the space to Cyan-BG 'xBQ'" do
              expect(@board.rows[0][3]).to be_instance_of(Queen)
              @board.mark("D8")
              expect(@board.rows[0][3]).to eql("\e[46mxBQ\e[0m")
            end
          end

          context "when Pawn" do
            it "sets the space to Cyan-BG 'xBP'" do
              expect(@board.rows[1][2]).to be_instance_of(Pawn)
              @board.mark("C7")
              expect(@board.rows[1][2]).to eql("\e[46mxBP\e[0m")
            end
          end
        end
      end
    end
  end

  describe ".line" do
    context "when given inadequate # of input" do
      it "raises an ArgumentError" do
        expect{Board.line()}.to raise_error(ArgumentError)
        expect{Board.line("A4")}.to raise_error(ArgumentError)
        expect{Board.line(:left)}.to raise_error(ArgumentError)
      end
    end

    context "when given input" do
      context "if input is incorrect data type" do
        it "raises ArgumentError" do
          expect{Board.line("left", :up)}.to raise_error("Input must be String, and Symbol")
          expect{Board.line(45, :down)}.to raise_error("Input must be String, and Symbol")
        end
      end

      context "if input is correct data type" do
        context "but input is not recognized" do
          it "raises ArgumentError" do
            expect{Board.line("A1", :around)}.to raise_error(StandardError, "around not recognized")
            expect{Board.line("B4", :behind)}.to raise_error(StandardError, "behind not recognized")
          end
        end

        context "and input is recognized" do
          it "returns String" do
            expect(Board.line("A1", :up)).to be_instance_of(String)
          end
        end
      end
    end
  end
end