class Player
  attr_reader :team_color, :board
  def initialize(team_sym=nil, host_board=nil)
    t = team_sym.is_a? Symbol
    b = host_board.is_a? Board
    raise ArgumentError.new("Requires team_color Symbol, and Board reference") unless t && b
    @team_color = team_sym
    @board = host_board
  end
end

class Artificial < Player; end