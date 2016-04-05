require_relative "spec_helper.rb"

describe Piece do
  describe "#new" do
    context "when given no input" do
      it "raises error" do
        expect{Piece.new}.to raise_error(ArgumentError, "Piece must be given team_color")
      end
    end

    context "when given input" do
      context "and input is invalid data type or Missing parameter" do
        it "raises ArgumentError" do
          expect{Piece.new("Poopy")}.to raise_error(ArgumentError, "requires Symbol of team_color")
          expect{Piece.new(4, "5,3")}.to raise_error(ArgumentError)
          expect{Piece.new(:white)}.not_to raise_error
        end
      end

      context "and input is correct" do
        before(:each) do
          @whitepiece = Piece.new(:white)
          @blackpiece = Piece.new(:black)
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
      @piece = Piece.new(:white)
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
      @piece = Piece.new(:white)
    end

    it "returns a Symbol" do
      expect(@piece.team_color).to be_instance_of(Symbol)
    end

    it "is set to initialized value" do
      white_piece = Piece.new(:white)
      black_piece = Piece.new(:black)

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

  describe ".ping" do
    before(:each) do
      @empty_board = Array.new(8, Array.new(8, " "))
      @piece = Piece.new(:white)
    end

    context "when given invalid # of params" do
      it "raises ArgumentError" do
        expect{@piece.ping()}.to raise_error(ArgumentError)
        expect{@piece.ping(@empty_board)}.to raise_error(ArgumentError)
        expect{@piece.ping(@empty_board, "A1")}.to raise_error(ArgumentError)
        expect{@piece.ping(@empty_board, "A1", :left)}.not_to raise_error(ArgumentError)
        expect{@piece.ping(@empty_board, "A1", :left, 5)}.not_to raise_error(ArgumentError)
        expect{@piece.ping(@empty_board, "A1", :left, 0, "uhh")}.to raise_error(ArgumentError)
      end
    end

    context "when given correct # of params" do
      context "if input are incorrect" do
        it "raises Error" do
          expect{@piece.ping([], "B2", :down)}.to raise_error(ArgumentError, "Row must be 8x8")
          expect{@piece.ping(@empty_board, "D9", :left)}.to raise_error(ArgumentError, "Input incorrect. Example: C4, B2, A3, etc.")
          expect{@piece.ping(@empty_board, "poop", :left)}.to raise_error(ArgumentError, "Input incorrect. Example: C4, B2, A3, etc.")
          expect{@piece.ping(@empty_board, "A2", :top)}.to raise_error(StandardError, "top not recognized")
          expect{@piece.ping(@empty_board, "D5", :left, "caca")}.to raise_error("Distance must be Integer")
        end
      end

      context "if input are valid" do
        it "does not raise error" do
          expect{@piece.ping(@empty_board, "C4", :left)}.not_to raise_error
        end

        it "returns an Array" do
          expect(@piece.ping(@empty_board, "C4", :left)).to be_instance_of(Array)
        end

        context "if given left" do
          it "returns Array of Coordinates to the left" do
            expect(@piece.ping(@empty_board, "D4", :left)).to eql(%w(C4 B4 A4))
          end
        end

        context "if given right" do
          it "returns Array of Coordinates to the right" do
            expect(@piece.ping(@empty_board, "D4", :right)).to eql(%w(E4 F4 G4 H4))
          end
        end

        context "if given others" do
          it "returns appropriate Array of Coordinates" do
            expect(@piece.ping(@empty_board, "D4", :up)).to eql(%w(D5 D6 D7 D8))
            expect(@piece.ping(@empty_board, "D4", :down)).to eql(%w(D3 D2 D1))
            expect(@piece.ping(@empty_board, "D4", :upright)).to eql(%w(E5 F6 G7 H8))
          end
        end

        context "when it runs into another piece" do
          before(:each) do
            @empty_board = Array.new(8, Array.new(8, " "))
            @piece = Piece.new(:white)
          end
          context "if the piece is an Ally" do

          end

          context "if the piece is an Enemy" do

          end
        end
      end
    end
  end
end