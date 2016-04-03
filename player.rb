class Player
  attr_reader :team_color, :board

  def self.coord_string(input_string)
    raise ArgumentError.new("Input must be String") unless input_string.is_a? String
    input_string = input_string.gsub(/\s+/, "").upcase
    raise ArgumentError.new("Input incorrect. Example: C4, B2, A3, etc.") unless input_string =~ /[A-H][1-8]/

    [8-input_string[1].to_i, input_string[0].ord - 65]
  end

  def initialize(team_sym=nil, host_board=nil)
    t = team_sym.is_a? Symbol #Boolean
    b = host_board.is_a? Board #Boolean
    #Raise an Error unless both both have been set correctly
    raise ArgumentError.new("Requires team_color Symbol, and Board reference") unless t && b
    @team_color = team_sym
    @board = host_board
  end

  def select(input_string)
    row, pos = Player.coord_string(input_string)
    piece = @board.rows[row][pos]
    raise StandardError.new("Space is empty") if piece == " "
    raise StandardError.new("Not your piece") unless piece.team_color == @team_color
    piece
  end
end

class Artificial < Player; end