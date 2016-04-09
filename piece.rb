class Piece
  attr_reader :display, :team_color, :directions, :moved, :distance
  
  def self.directions
    [:up, :down, :left, :right]
  end

  def self.diagonals
    [:upleft, :upright, :downleft, :downright]
  end
  
  def initialize(color_sym = nil, host_board)
    raise ArgumentError.new("Piece must be given team_color") if color_sym.nil?
    raise ArgumentError.new("requires Symbol of team_color") unless color_sym.is_a? Symbol
    @team_color = color_sym
    
    #Create a display made of the piece's COLOR, and Piece type(Class)
    #and turn it into a Symbol
    @display = "#{@team_color.to_s[0].upcase}#{self.class.to_s[0].upcase}".to_sym
    @distance = 0
    @moved = false
    @board = host_board
  end

  def move
    @moved = true
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
  def initialize(color_sym=nil, host_board)
    super(color_sym, host_board)
    @distance = 1
    @directions = [:up, :upleft, :upright]
  end

  def moves(input_rows, start_pos, distance = @distance, display = true)
    potential_moves = super(input_rows, start_pos, distance, false) #Get an array of Coordinates upleft - upright

    temp_rows = input_rows.map(&:dup) #Copy rows so we can fuck with em

    up = potential_moves.select {|elem| elem[0] == start_pos[0]} #Filter out only directly up Coordinates
    diag = potential_moves - up #Filter out diagonals

    unless up.empty? 
      up_row, up_pos = Player.coord_string(up.first)
      up_piece = temp_rows[up_row][up_pos] #Figure out what the piece above is
      if up_piece.is_a? Piece #If it's a piece(Because pawn's can't cap spaces ahead, only diag)
        up = up - [up.first] #Remove it.
      else #If it's not a piece(Ergo, free space above us)
        unless @moved #Find out if we moved already
          next_coord = Board.line(up.first, :up) #If we haven't moved, we get another jump, check the next space
          next_space = temp_rows[Player.coord_string(next_coord)[0]][Player.coord_string(next_coord)[1]] #Get reference of that object
          if next_space == " " #If it's free to move to
            up << next_coord #Add it to the queue of places to jump
          end
        end
      end

      up.each do |pos|
        Board.mark(temp_rows, pos) #Then mark all the places we can get to.
      end
    end

    diag.each do |pos| #As for the diagonals
      current_piece = temp_rows[Player.coord_string(pos)[0]][Player.coord_string(pos)[1]]
      if current_piece.is_a? Piece #If the diagonal space is a piece
        if current_piece.team_color != @team_color #Check if it's an enemy
          Board.mark(temp_rows, pos) #If so, mark em for Capping
        end
      else #If it's not a piece
        diag = diag - [pos] #Remove it from the potential moves, we can't just jump diagonal willy-nilly
      end
    end

    puts Board.table(temp_rows) if display #Print out a display of potential moves
    up + diag #Then return the array of potentials
  end
end

class Knight < Piece
  attr_reader :horizontals, :verticals
  def initialize(color_sym=nil, host_board)
    super(color_sym, host_board)
    #Knights and Kings have the same Class initial
    #Knights will have an n after their K, to make them distinct
    @display = (@display.to_s + "n").to_sym
    @verticals = Piece.directions[0..1]
    @horizontals = Piece.directions[2..3]
  end

  def moves(input_rows, start_pos, distance = @distance, display = true)
    temp_rows = input_rows.map(&:dup) #Copy rows so we can fuck with em
    potential_moves = []

      @verticals.each do |symbol|
        begin
          two_away = Board.line(Board.line(start_pos, symbol), symbol) #up, up/down, down
          @horizontals.each do |h_symbol| 
            potential_moves = potential_moves + ping(temp_rows, two_away, h_symbol, 1) #left, right
          end
        rescue ArgumentError => e
          next
        end
      end

      @horizontals.each do |symbol|
        begin
          two_away = Board.line(Board.line(start_pos, symbol), symbol) #left, left/ right, right

          @verticals.each do |v_symbol|
            potential_moves = potential_moves + ping(temp_rows, two_away, v_symbol, 1)#up,down
          end
        rescue ArgumentError => e
          next
        end
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

  def moves(input_rows, start_pos, distance = @distance, display = true)
    moves = super(input_rows, start_pos, distance, false)
    throwaway = input_rows.map(&:dup)
    acceptable = []

    moves.each do |coord|
      acceptable = acceptable + [coord] unless threatened(input_rows, coord)
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
    dir = Piece.directions + Piece.diagonals
    dir.each do |symbol|
      row, pos = Player.coord_string(Board.line(space, symbol))
      current = input_rows[row][pos]

      if current.is_a? King
        return true if current.team_color != @team_color
      end
    end
    false
  end

  def pawn_check(input_rows, space)
    to_check = [Board.line(space, :upright), Board.line(space, :upleft)]
    to_check.each do |coord|
      current = input_rows[Player.coord_string(coord)[0]][Player.coord_string(coord)[1]]
      if current.is_a? Pawn
        return true if current.team_color != @team_color
      end
    end
    false
  end

  def bishop_check(input_rows, space)
    potentials = []
    throwaway = input_rows.map(&:dup)

    Piece.diagonals.each do |symbol|
      #def ping(edit_array, start, direction, counter=0)
      potentials = potentials + ping(throwaway, space, symbol)
    end

    pieces = potentials.select do |coord|
      current = input_rows[Player.coord_string(coord)[0]][Player.coord_string(coord)[1]]
      current.is_a? Piece
    end

    pieces.any? do |piece|
      current = input_rows[Player.coord_string(piece)[0]][Player.coord_string(piece)[1]]
      r = current.is_a? Bishop
      q = current.is_a? Queen

      r || q
    end
  end

  def rook_check(input_rows, space)
    potentials = []
    throwaway = input_rows.map(&:dup)

    Piece.directions.each do |symbol|
      #def ping(edit_array, start, direction, counter=0)
      potentials = potentials + ping(throwaway, space, symbol)
    end

    pieces = potentials.select do |coord|
      current = input_rows[Player.coord_string(coord)[0]][Player.coord_string(coord)[1]]
      current.is_a? Piece
    end

    pieces.any? do |piece|
      current = input_rows[Player.coord_string(piece)[0]][Player.coord_string(piece)[1]]
      r = current.is_a? Rook
      q = current.is_a? Queen

      r || q
    end
  end

  def knight_check(input_rows, space)
    knight = Knight.new(@team_color, @board)
    potential_knights = []

    knight.verticals.each do |symbol|
      one_away = Board.line(space, symbol) #up, down
      knight.horizontals.each do |h_symbol| 
        target = Board.line(Board.line(one_away, h_symbol), h_symbol) #left, left/right, right
        potential_knights = potential_knights + [target]
      end
    end

    knight.horizontals.each do |symbol|
      one_away = Board.line(space, symbol) #left, right
      knight.verticals.each do |v_symbol| 
        target = Board.line(Board.line(one_away, v_symbol), v_symbol) #up, up/down, down
        potential_knights = potential_knights + [target]
      end
    end

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