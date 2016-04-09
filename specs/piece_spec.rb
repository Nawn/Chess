require_relative "spec_helper.rb"

describe Piece do
  describe "#new" do
    context "when given no input" do
      it "raises error" do
        expect{Piece.new}.to raise_error(ArgumentError)
      end
    end

    context "when given input" do
      before(:each) do
        @board = Board.new
      end
      context "and input is invalid data type or Missing parameter" do
        it "raises ArgumentError" do
          expect{Piece.new("Poopy")}.to raise_error(ArgumentError)
          expect{Piece.new(4, "5,3")}.to raise_error(ArgumentError)
          expect{Piece.new(:white, @board)}.not_to raise_error
        end
      end

      context "and input is correct" do
        before(:each) do
          @board = Board.new
          @whitepiece = Piece.new(:white, @board)
          @blackpiece = Piece.new(:black, @board)
        end

        it "creates piece object" do
          expect(@whitepiece).to be_instance_of(Piece)
          expect(@blackpiece).to be_instance_of(Piece)
        end
      end
    end
  end

  describe "#display" do
    before(:each) do
      @board = Board.new
      @piece = Piece.new(:white, @board)
    end

    it "returns a Symbol" do
      expect(@piece.display).to be_instance_of(Symbol)
    end

    it "returns a Symbol with the Initials of team_color and Piece Type" do
      expect(@piece.display).to eql(:WP)
    end

    context "when attempt to assign to display" do
      it "raises NoMethodError" do
        expect{@piece.display = :black}.to raise_error(NoMethodError)
      end
    end
  end

  describe "#team_color" do
    before(:each) do
      @board = Board.new
      @piece = Piece.new(:white, @board)
    end

    it "returns a Symbol" do
      expect(@piece.team_color).to be_instance_of(Symbol)
    end

    it "is set to initialized value" do
      white_piece = Piece.new(:white, @board)
      black_piece = Piece.new(:black, @board)

      expect(white_piece.team_color).to eql(:white)
      expect(black_piece.team_color).to eql(:black)
    end
  end

  describe ".directions" do
    it "can be read" do
      expect{Piece.directions}.not_to raise_error
    end

    it "returns an Array" do
      expect(Piece.directions).to be_instance_of(Array)
    end

    it "contains 4 direction Symbols" do
      expect(Piece.directions).to eql([:up,:down,:left,:right])
    end
  end

  describe "#ping" do
    before(:each) do
      empty_row = Array.new(8, " ")
      final_rows = []
      8.times do |index|
        final_rows[index] = empty_row.clone
      end
      @empty_board = Board.new
      @empty_board.rows = final_rows
      @piece = Piece.new(:white, @empty_board)
      @piece.position = "D4"
      @empty_board.rows[4][3] = @piece
    end

    context "when given invalid # of params" do
      it "raises ArgumentError" do
        expect{@piece.ping()}.to raise_error(ArgumentError)
        expect{@piece.ping(:left)}.not_to raise_error
        expect{@piece.ping(:left, 5)}.not_to raise_error
        expect{@piece.ping(:left, 0, "D4")}.not_to raise_error
        expect{@piece.ping(:left, 0, "D4", [])}.to raise_error(ArgumentError)
      end
    end

    context "when given correct # of params" do
      context "if input are incorrect" do
        it "raises Error" do
          expect{@piece.ping(:top)}.to raise_error(StandardError, "top not recognized")
          expect{@piece.ping(:left, "caca")}.to raise_error(ArgumentError, "Distance must be Integer")
        end
      end

      #def ping(direction, counter=0, start = @position)
      context "if input are valid" do
        it "does not raise error" do
          expect{@piece.ping(:left)}.not_to raise_error
        end

        it "returns an Array" do
          expect(@piece.ping(:left)).to be_instance_of(Array)
        end

        context "if given left" do
          it "returns Array of Coordinates to the left" do
            expect(@piece.ping(:left)).to eql(%w(C4 B4 A4))
          end
        end

        context "if given right" do
          it "returns Array of Coordinates to the right" do
            expect(@piece.ping(:right)).to eql(%w(E4 F4 G4 H4))
          end
        end

        context "if given others" do
          it "returns appropriate Array of Coordinates" do
            expect(@piece.ping(:up)).to eql(%w(D5 D6 D7 D8))
            expect(@piece.ping(:down)).to eql(%w(D3 D2 D1))
            expect(@piece.ping(:upright)).to eql(%w(E5 F6 G7 H8))
          end
        end

        context "when it runs into another piece" do
          before(:each) do
            empty = @empty_board.rows.map(&:dup)
            to_add = [["D8", :white], ["B6", :black], ["D2", :black], ["F2", :white]]
            to_add.each do |array|
              row, pos = Player.coord_string(array[0])
              empty[row][pos] = Pawn.new(array[1], @empty_board)
            end
            @empty_board.rows = empty
            @empty_board.rows[4][3] = @piece = Piece.new(:white, @empty_board)
            @piece.position = "D4"
          end

          context "if the piece is an Ally" do
            it "terminates early, and returns Array" do
              expect(@piece.ping(:up)).to eql(%w(D5 D6 D7))
              expect(@piece.ping(:downright)).to eql(%w(E3))
            end
          end

          context "if the piece is an Enemy" do
            it "terminates early, and returns Array including enemy Piece coord" do
              expect(@piece.ping(:upleft)).to eql(%w(C5 B6))
              expect(@piece.ping(:down)).to eql(%w(D3 D2))
            end
          end
        end

        context "when given distance param" do
          it "only pings that far" do
            expect(@piece.ping(:upright, 3)).to eql(%w(E5 F6 G7))
            expect(@piece.ping(:downleft, 2)).to eql(%w(C3 B2))
          end

          it "will terminate early if nothing left to check" do
            @piece.position = "E7"
            expect(@piece.ping(:upleft, 3)).to eql(%w(D8))
          end
        end
      end
    end
  end
end