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
          expect{Piece.new(4, "5,3")}.to raise_error(ArgumentError, "requires Symbol of team_color")
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
end