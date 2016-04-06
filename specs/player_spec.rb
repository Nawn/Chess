require_relative "spec_helper.rb"

describe Player do
  describe "#new" do
    context "when given no input" do
      it "raises ArgumentError" do
        expect{Player.new}.to raise_error(ArgumentError, "Requires team_color Symbol, and Board reference")
      end
    end

    context "when given input" do
      context "and input has incorrect number of parameters" do
        it "raises ArgumentError" do
          expect{Player.new(4, [], :apple)}.to raise_error(ArgumentError)
          expect{Player.new(5, 5, 5, 4)}.to raise_error(ArgumentError)
        end
      end

      context "when input is incorrect type" do
        it "raises ArgumentError" do
          expect{Player.new("black", 5)}.to raise_error(ArgumentError, "Requires team_color Symbol, and Board reference")
        end
      end

      context "when input is correct" do
        before(:each) do
          @board = Board.new
          @player = Player.new(:black, @board)
        end

        it "does not raise error" do
          expect{Player.new(:white, Board.new)}.not_to raise_error
        end

        it "creates a new Player object" do
          expect(@player).to be_instance_of(Player)
        end
      end
    end
  end

  describe "#team_color" do
    before(:each) do
      @player = Player.new(:white, Board.new)
    end

    it "is set to Symbol initialzied and can be read" do
      expect(@player.team_color).to eql(:white)
    end

    it "is cannot be set" do
      expect{@player.team_color = :black}.to raise_error(NoMethodError)
    end
  end

  describe "#board" do
    before(:each) do
      @board = Board.new
      @player = Player.new(:white, @board)
    end

    it "can be read" do
      expect{@player.board}.not_to raise_error
    end

    it "is a Board object" do
      expect(@player.board).to be_instance_of(Board)
    end

    it "is the initialized board" do
      expect(@player.board).to eql(@board)
    end
  end

  describe "#select" do
    before(:each) do
      @board = Board.new
      @player1 = @board.players[0]
      @player2 = @board.players[1]
    end

    context "when given no input" do
      it "raises ArgumentError" do
        expect{@player1.select()}.to raise_error(ArgumentError)
      end
    end

    context "when given input" do
      context "and input is not String" do
        it "raises ArgumentError" do
          expect{@player1.select(['poop'])}.to raise_error(ArgumentError, "Input must be String")
          expect{@player1.select(5)}.to raise_error(ArgumentError, "Input must be String")
          expect{@player1.select(:incorrect)}.to raise_error(ArgumentError, "Input must be String")
        end
      end

      context "and input is string" do
        context "but string is not valid" do
          it "raises ArgumentError" do
            expect{@player1.select("poop")}.to raise_error(ArgumentError, "Input incorrect. Example: C4, B2, A3, etc.")
            expect{@player1.select("4C")}.to raise_error(ArgumentError, "Input incorrect. Example: C4, B2, A3, etc.")
            expect{@player1.select("top left")}.to raise_error(ArgumentError, "Input incorrect. Example: C4, B2, A3, etc.")
          end
        end

        context "when input is valid" do
          it "does not raise error" do
            expect{@player1.select("C2")}.not_to raise_error
            expect{@player1.select("C 2")}.not_to raise_error
            expect{@player1.select("  C  2  ")}.not_to raise_error
          end

          context "when space is invalid" do
            context "where space has enemy piece" do
              it "raises StandardError" do
                expect{@player1.select("A8")}.to raise_error(StandardError, "Not your piece")
                expect{@player1.select("C7")}.to raise_error(StandardError, "Not your piece")
                expect{@player2.select("A1")}.to raise_error(StandardError, "Not your piece")
                @board.flip
                expect{@player1.select("A1")}.to raise_error(StandardError, "Not your piece")
                expect{@player2.select("A8")}.to raise_error(StandardError, "Not your piece")
              end
            end

            context "where space is empty" do
              it "raises StandardError" do
                expect{@player1.select("C3")}.to raise_error(StandardError, "Space is empty")
                expect{@player1.select("D6")}.to raise_error(StandardError, "Space is empty")
                expect{@player2.select("C4")}.to raise_error(StandardError, "Space is empty")
              end
            end
          end

          context "when space is valid" do
            it "returns a Piece" do
              piece = @player1.select("A1")
              expect(piece).to be_kind_of(Piece)
            end

            it "Returns the object in space provided" do
              expect(@player1.select("B1")).to be_instance_of(Knight)
              expect(@player1.select("D1")).to be_instance_of(Queen)
              expect(@player1.select("D2")).to be_instance_of(Pawn)
              expect(@player1.select("B1")).to eql(@board.rows[7][1])
            end
          end
        end
      end
    end
  end

  describe "#move" do
    before(:each) do
      @board = Board.new
      @player1 = @board.players[0]
      @player2 = @board.players[1]
    end

    it "accepts 2 coordinates" do
      expect{@player1.move("A2", "A4")}.not_to raise_error
    end

    it "accepts 2 coordinates, and input_rows" do
      expect{@player1.move("A2", "A4", @board.rows)}.not_to raise_error
    end

    it "does not take less than 2 or more than 3 Arguments" do
      expect{@player1.move()}.to raise_error(ArgumentError)
      expect{@player1.move("A2")}.to raise_error(ArgumentError)
      expect{@player1.move("A2", "A4", @board.rows, 5)}.to raise_error(ArgumentError)
    end

    context "when given invalid inputs" do
      context "if input are not String" do
        it "raises ArgumentError" do
          expect{@player1.move(5, "A4")}.to raise_error(ArgumentError)
          expect{@player1.move("A2", 5)}.to raise_error(ArgumentError)
        end
      end

      context "if locations are invalid" do
        
      end
    end
  end
end