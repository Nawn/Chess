class Piece
  attr_reader :display, :team_color
  def self.directions
    [:up, :down, :left, :right]
  end
  
  def initialize(color_sym = nil)
    raise ArgumentError.new("Piece must be given team_color") if color_sym.nil?
    raise ArgumentError.new("requires Symbol of team_color") unless color_sym.is_a? Symbol
    @team_color = color_sym
    
    #Create a display made of the piece's COLOR, and Piece type(Class)
    #and turn it into a Symbol
    @display = "#{@team_color.to_s[0].upcase}#{self.class.to_s[0].upcase}".to_sym 
  end

  def ping(edit_array, start, direction, counter=0)
    raise ArgumentError.new("Rows must be String") unless edit_array.is_a? Array
    row_size = edit_array.size == 8
    raise ArgumentError.new("Row must be 8x8") unless row_size
    raise ArgumentError.new("Distance must be Integer") unless counter.is_a? Integer

    current_row, current_position = Player.coord_string(start)
    next_space = Board.line(start, direction)
    []
  end
end

class Pawn < Piece; end

class Knight < Piece
  def initialize(color_sym=nil)
    super(color_sym)
    #Knights and Kings have the same Class initial
    #Knights will have an n after their K, to make them distinct
    @display = (@display.to_s + "n").to_sym 
  end
end

class Rook < Piece; end

class Bishop < Piece; end

class King < Piece; end

class Queen < Piece; end