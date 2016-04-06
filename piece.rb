class Piece
  attr_reader :display, :team_color, :directions, :moved
  
  def self.directions
    [:up, :down, :left, :right]
  end

  def self.diagonals
    [:upleft, :upright, :downleft, :downright]
  end
  
  def initialize(color_sym = nil)
    raise ArgumentError.new("Piece must be given team_color") if color_sym.nil?
    raise ArgumentError.new("requires Symbol of team_color") unless color_sym.is_a? Symbol
    @team_color = color_sym
    
    #Create a display made of the piece's COLOR, and Piece type(Class)
    #and turn it into a Symbol
    @display = "#{@team_color.to_s[0].upcase}#{self.class.to_s[0].upcase}".to_sym
    @distance = 0
    @moved = false
  end

  def ping(edit_array, start, direction, counter=0)
    raise ArgumentError.new("Rows must be String") unless edit_array.is_a? Array
    row_size = edit_array.size == 8 && edit_array.all? {|row| row.size == 8}
    raise ArgumentError.new("Row must be 8x8") unless row_size
    raise ArgumentError.new("Distance must be Integer") unless counter.is_a? Integer

    next_space = Board.line(start, direction)
    begin
      current_row, current_position = Player.coord_string(next_space) #Current as in the one we're looking at
    rescue ArgumentError => e
      return []
    end
    current_piece = edit_array[current_row][current_position] #Current piece is whatever we currently have


    if current_piece.is_a? Piece
      if current_piece.team_color == @team_color #If it's on the same team
        return [] #Return nothing but an empty ary as to not include this pos as an option
      else
        edit_array[current_row][current_position] = "\e[46m#{current_piece.display}\e[0m" #Change the spot to a highlighted square
        return [next_space] #Return this pos as a potential option
      end
    else
      edit_array[current_row][current_position] = :X #If it's not a Piece, rather an empty space
      return [next_space] if counter == 1 #If we set a limit, and we're at 1, that means this is the last empty spot
      return ([next_space] + ping(edit_array, next_space, direction, counter)) if counter.zero? #If it's 0, then that means we didn't set a counter
      return ([next_space] + ping(edit_array, next_space, direction, counter-1)) #If we did set a counter, then return the next with a -1 to counter.
    end
  end

  def moves(input_rows, start_pos, distance = @distance, display = true)
    r = input_rows.is_a? Array
    s = start_pos.is_a? String
    raise ArgumentError.new("Input must be 8x8 Array, and Coordinate") unless r && s
    #Error Handling

    print_rows = input_rows.map(&:dup) #Create a copy of the Board to fuck with
    potentials = [] #Declare empty array to hold all potentials

    @directions.each do |symbol|
      potentials = potentials + ping(print_rows, start_pos, symbol, distance) #For each direction you can go, 
    end

    puts Board.table(print_rows) if display
    potentials
  end
end

class Pawn < Piece
  def initialize(color_sym=nil)
    super(color_sym)
    @distance = 1
    @directions = [:up, :upleft, :upright]
  end

  def moves(input_rows, start_pos, distance = @distance)
    potential_moves = super(input_rows, start_pos, distance, false)

    temp_rows = input_rows.map(&:dup)

    up = potential_moves.select {|elem| elem[0] == start_pos[0]}
    diag = potential_moves - up

    unless up.empty?
      up_row, up_pos = Player.coord_string(up.first)
      up_piece = temp_rows[up_row][up_pos]
      if up_piece.is_a? Piece
        up = up - [up.first]
      else
        unless @moved
          next_coord = Board.line(up.first, :up)
          next_row, next_pos = Player.coord_string(next_coord)
          next_space = temp_rows[next_row][next_pos]
          if next_space == " "
            up << next_coord
          end
        end
      end

      up.each do |pos|
        Board.mark(temp_rows, pos)
      end
    end

    diag.each do |pos|
      cur_row, cur_pos = Player.coord_string(pos)
      current_piece = temp_rows[cur_row][cur_pos]
      if current_piece.is_a? Piece
        if current_piece.team_color != @team_color
          Board.mark(temp_rows, pos)
        end
      else
        diag = diag - [pos]
      end
    end

    puts Board.table(temp_rows)
    up + diag
  end
end

class Knight < Piece
  def initialize(color_sym=nil)
    super(color_sym)
    #Knights and Kings have the same Class initial
    #Knights will have an n after their K, to make them distinct
    @display = (@display.to_s + "n").to_sym 
  end
end

class Rook < Piece
  def initialize(color_sym=nil)
    super(color_sym)
    @directions = Piece.directions.clone
  end
end

class Bishop < Piece
  def initialize(color_sym=nil)
    super(color_sym)
    @directions = Piece.diagonals.clone
  end
end

class King < Piece; end

class Queen < Piece
  def initialize(color_sym=nil)
    super(color_sym)
    @directions = Piece.directions.clone + Piece.diagonals.clone
  end
end