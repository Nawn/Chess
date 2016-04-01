class Piece
  attr_reader :display, :team_color
  def initialize(color_sym = nil)
    raise ArgumentError.new("Piece must be given team_color") if color_sym.nil?
    raise ArgumentError.new("requires Symbol of team_color") unless color_sym.is_a? Symbol
    @team_color = color_sym
    @display = "#{@team_color.to_s[0].upcase}#{self.class.to_s[0].upcase}".to_sym
  end
end

class Pawn < Piece; end

class Knight < Piece
  def initialize(color_sym=nil)
    super(color_sym)
    @display = (@display.to_s + "n").to_sym 
  end
end

class Rook < Piece; end

class Bishop < Piece; end

class King < Piece; end

class Queen < Piece; end