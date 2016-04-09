class Piece
  attr_writer :position
  attr_reader :display, :team_color, :directions, :moved
  
  def self.directions
    [:up, :down, :left, :right]
  end

  def self.diagonals
    [:upleft, :upright, :downleft, :downright]
  end
  
  def initialize(color_sym, host_board)
    raise ArgumentError.new("requires Symbol of team_color") unless color_sym.is_a? Symbol
    @team_color = color_sym
    
    #Create a display made of the piece's COLOR, and Piece type(Class)
    #and turn it into a Symbol
    @display = "#{@team_color.to_s[0].upcase}#{self.class.to_s[0].upcase}".to_sym
    @distance = 0
    @moved = false
    @board = host_board
    @position = nil
  end

  def move(input_coord)
    @moved = true
    @position = input_coord
  end

  def ping(direction, counter=0, start = @position)
    raise ArgumentError.new("Rows must be String") unless @board.rows.is_a? Array
    row_size = @board.rows.size == 8 && @board.rows.all? {|row| row.size == 8}
    raise ArgumentError.new("Row must be 8x8") unless row_size
    raise ArgumentError.new("Distance must be Integer") unless counter.is_a? Integer

    next_space = Board.line(start, direction)
    begin
      current_piece = @board.select(next_space) 
    rescue ArgumentError => e
      return []
    end
    #Current piece is whatever we currently have


    if current_piece.is_a? Piece
      if current_piece.team_color == @team_color #If it's on the same team
        return [] #Return nothing but an empty ary as to not include this pos as an option
      else
        return [next_space] #Return this pos as a potential option
      end
    else
      return [next_space] if counter == 1 #If we set a limit, and we're at 1, that means this is the last empty spot
      return ([next_space] + ping(direction, counter, next_space)) if counter.zero? #If it's 0, then that means we didn't set a counter
      return ([next_space] + ping(direction, counter-1, next_space)) #If we did set a counter, then return the next with a -1 to counter.
    end
  end

  def moves(display = true)
    r = @board.rows.is_a? Array
    s = @position.is_a? String
    raise ArgumentError.new("Input must be 8x8 Array, and Coordinate") unless r && s
    #Error Handling

    print_rows = @board.rows.map(&:dup) #Create a copy of the Board to fuck with
    potentials = [] #Declare empty array to hold all potentials

    @directions.each do |symbol|
      potentials = potentials + ping(symbol, @distance) #For each direction you can go, 
    end

    potentials.each do |coord|
      Board.mark(print_rows, coord)
    end

    puts Board.table(print_rows) if display
    potentials
  end
end

class Pawn < Piece
  def initialize(color_sym, host_board)
    super(color_sym, host_board)
    @distance = 1
    @directions = [:up, :upleft, :upright]
  end

  def moves(display = true)
    moves = {}
    @directions.each do |direction|
      moves[direction] = Board.line(@position, direction)
    end
    potentials = []

    moves.each do |key, value|
      if key == :up
        up_piece = @board.select(value)
        unless up_piece.is_a?(Piece)
          potentials = potentials + [value]
          second_piece = Board.line(value, key)
          unless @board.select(second_piece).is_a?(Piece)
            potentials = potentials + [second_piece] unless @moved
          end
        end
      else
        cur_piece = @board.select(value)
        if cur_piece.is_a? Piece
          potentials = potentials + [value] if cur_piece.team_color != @team_color
        end
      end
    end

    print_rows = @board.rows.map(&:dup)
    potentials.each {|coord| Board.mark(print_rows, coord)}

    puts Board.table(print_rows)
    potentials
  end
end

class Knight < Piece
  attr_reader :horizontals, :verticals
  def initialize(color_sym, host_board)
    super(color_sym, host_board)
    #Knights and Kings have the same Class initial
    #Knights will have an n after their K, to make them distinct
    @display = (@display.to_s + "n").to_sym
    @verticals = Piece.directions[0..1]
    @horizontals = Piece.directions[2..3]
  end

  def moves(display = true)
    potential_moves = []

    @verticals.each do |symbol|
      begin
        two_away = Board.line(Board.line(@position, symbol), symbol) #up, up/down, down
        @horizontals.each do |h_symbol|
          potential_moves = potential_moves + ping(h_symbol, 1, two_away) #left, right
        end
      rescue ArgumentError => e
        next
      end
    end

    @horizontals.each do |symbol|
      begin
        two_away = Board.line(Board.line(@position, symbol), symbol) #left, left/ right, right

        @verticals.each do |v_symbol|
          potential_moves = potential_moves + ping(v_symbol, 1, two_away)#up,down
        end
      rescue ArgumentError => e
        next
      end
    end

    temp_rows = @board.rows.map(&:dup)

    potential_moves.each do |coord|
      Board.mark(temp_rows, coord)
    end

    puts Board.table(temp_rows) if display
    potential_moves
  end
end

class King < Piece
  def initialize(color_sym=nil, host_board)
    super(color_sym, host_board)
    @directions = Piece.directions.clone + Piece.diagonals.clone
    @distance = 1
  end

  def moves(display = true)
    moves = super(false)
    throwaway = @board.rows.map(&:dup)
    acceptable = []

    moves.each do |coord|
      acceptable = acceptable + [coord] unless threatened(throwaway, coord)
    end
    
    acceptable.each do |coord|
      Board.mark(throwaway, coord)
    end

    puts Board.table(throwaway) if display
    acceptable
  end

  private
  def threatened(input_rows, space)
    knight_check(input_rows, space) || rook_check(input_rows, space) || bishop_check(input_rows, space) || pawn_check(input_rows, space) || king_check(input_rows, space)
  end

  def king_check(input_rows, space)
    @directions.each do |symbol|
      begin
        current = Board.select(input_rows, Board.line(space, symbol))

        if current.is_a? King
          return true if current.team_color != @team_color
        end
      rescue
        next
      end
    end
    false
  end

  def pawn_check(input_rows, space)
    to_check = [Board.line(space, :upright), Board.line(space, :upleft)]
    to_check.each do |coord|
      begin
        current = Board.select(input_rows, coord)
        if current.is_a? Pawn
          return true if current.team_color != @team_color
        end
      rescue
        next
      end
    end
    false
  end

  def bishop_check(input_rows, space)
    potentials = []

    Piece.diagonals.each do |symbol|
      #def ping(direction)
      potentials = potentials + ping(symbol, 0, space)
    end

    pieces = potentials.select do |coord|
      current = Board.select(input_rows, coord)
      current.is_a? Piece
    end

    pieces.any? do |piece|
      current = Board.select(input_rows, piece)
      r = current.is_a? Bishop
      q = current.is_a? Queen

      r || q
    end
  end

  def rook_check(input_rows, space)
    potentials = []

    Piece.directions.each do |symbol|
      #def ping(edit_array, start, direction, counter=0)
      potentials = potentials + ping(symbol, 0, space)
    end

    pieces = potentials.select do |coord|
      current = Board.select(input_rows, coord)
      current.is_a? Piece
    end

    pieces.any? do |piece|
      current = Board.select(input_rows, piece)
      r = current.is_a? Rook
      q = current.is_a? Queen

      r || q
    end
  end

  def knight_check(input_rows, space)
    knight = Knight.new(@team_color, @board)
    knight.position = space

    potential_knights = knight.moves(false)

    potential_knights.each do |coord|
      begin
        knight = Board.select(input_rows, coord)
        if knight.is_a? Knight
          return true if knight.team_color != @team_color
        end
      rescue
        next
      end
    end
    false
  end
end

class Rook < Piece
  def initialize(color_sym=nil, host_board)
    super(color_sym, host_board)
    @directions = Piece.directions.clone
  end
end

class Bishop < Piece
  def initialize(color_sym=nil, host_board)
    super(color_sym, host_board)
    @directions = Piece.diagonals.clone
  end
end


class Queen < Piece
  def initialize(color_sym=nil, host_board)
    super(color_sym, host_board)
    @directions = Piece.directions.clone + Piece.diagonals.clone
  end
end