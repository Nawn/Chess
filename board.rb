require 'terminal-table'
require_relative 'player.rb'
require_relative 'piece.rb'

#"\e[46m#{knight.display}\e[0m"

class Board
  attr_reader :rows, :players, :view

  def initialize (input_symbol = :multiplayer)
    raise ArgumentError.new("Incorrect input") unless input_symbol.is_a? Symbol

    case input_symbol #Depending on the input
    when :multiplayer 
      @players = [Player.new(:white, self), Player.new(:black, self)] #Make both players human
    when :singleplayer
      @players = [Player.new(:white, self), Artificial.new(:black, self)] #Make a Human vs AI
    else
      raise ArgumentError.new("#{input_symbol.to_s} is not acceptable input") #Raise Error, unacceptable input
    end

    @view = @players[0].team_color #Fresh board will let fist player go first
    @rows = new_board #Run fresh Chess Set up
  end

  #Returns a Terminal::Table Object
  def self.table(input_rows)
    rows = []
    temp_rows = input_rows.map { |e| e.map {|i| i.is_a?(Piece) ? i.display : i  } }
    8.times do |number|
      rows << [8-number] + temp_rows[number]
      rows << :separator
    end
    rows << ([" "] + Array("A".."H"))

    Terminal::Table.new :rows => rows    
  end

  def self.up(position)
    "#{position[0]}#{position[1].to_i+1}"
  end

  def self.down(position)
    "#{position[0]}#{position[1].to_i-1}"
  end

  def self.left(position)
    "#{(position[0].ord - 1).chr}#{position[1]}"
  end

  def self.right(position)
    "#{(position[0].ord + 1).chr}#{position[1]}"
  end

  def self.mark(input_rows, position, object=:X)
    row, position = Player.coord_string(position) #Run through the filter to get coordinates
    if input_rows[row][position].is_a? Piece
      piece = input_rows[row][position]
      input_rows[row][position] = "\e[46mx#{piece.display}\e[0m" #Mark that location on board
    else
      input_rows[row][position] = object #Set to X if it's a blank
    end
  end

  def self.line(position, direction)
    p_string = position.is_a? String
    d_string = direction.is_a? Symbol
    p_board = position =~ /[A-H][1-8]/
    raise ArgumentError.new("Input must be String, and Symbol") unless p_string && d_string
    raise ArgumentError.new("Input must be within board limits, got #{position}") unless p_board
    
    case direction
    when :up
      Board.up(position)
    when :down
      Board.down(position)
    when :right
      Board.right(position)
    when :left
      Board.left(position)
    when :upright
      Board.up(Board.right(position))
    when :upleft
      Board.up(Board.left(position))
    when :downleft
      Board.down(Board.left(position))
    when :downright
      Board.down(Board.right(position))
    else
      raise StandardError.new("#{direction} not recognized")
    end
  end

  def mark(position, object=:X)
    Board.mark(@rows, position, object)
  end

  def flip(color_sym=nil)
    flip_check(color_sym)

    if color_sym.nil? #if they set no input
      @players.each do |player| #Go through each player
        if @view != player.team_color #And compare their color to the current view
          #If the current view, does not match their color(Ergo, it's the next players view)
          @view = player.team_color #Set it to it
          break #And stop searching
        end
      end
      reverse()
    else
      unless color_sym == @view
        @view = color_sym
        reverse()
      end
    end
  end

  def display(input_rows=nil)
    #table() returns a Terminal::Table object, which is an ASCII board
    puts input_rows.nil? ? Board.table(@rows) : Board.table(input_rows)
  end

  private
  def new_board
    #Declarations
    empty_row = Array.new(8, " ")
    final_row = []
    #Set the top and bottom rows to be full of special pieces
    final_row[0], final_row[7] = war_row(@players[1].team_color), war_row(@players[0].team_color)
    #Set the next rows, to be full of pawns
    final_row[1], final_row[6] = pawn_row(@players[1].team_color), pawn_row(@players[0].team_color)
    2.upto(5) do |index| #Then for indices 2..5 (Empty space)
      final_row[index] = empty_row.clone #Set it to empty rows
    end
    final_row #Return the "Fresh board"
  end

  def flip_check(input_symbol)
    symbol = input_symbol.is_a? Symbol #Boolean, Check if input is Symbol
    unless input_symbol.nil? || symbol #Unless it's appropriate input
      raise ArgumentError.new("Input must be symbol") #Raise the error
    end

    #Unless it is someone's color, or nil(Because nil is acceptable)
    unless @players.any? { |player| player.team_color == input_symbol} || input_symbol.nil?
      acceptable = "" #Declare an empty string
      @players.each_with_index do |player, index|
        #If it's the first one, just add it, else, append to the rest
        acceptable += index.zero? ? ":#{player.team_color.to_s}" : ", or :#{player.team_color.to_s}"
      end
      #Then raise error with it as the message
      raise StandardError.new("Input must be #{acceptable}")
    end
  end

  #War_row is the row full of Kings, Queens, Rooks, etc.
  def war_row(team_color)
    return_row = []
    return_row[0], return_row[7] = Rook.new(team_color), Rook.new(team_color)
    return_row[1], return_row[6] = Knight.new(team_color), Knight.new(team_color)
    return_row[2], return_row[5] = Bishop.new(team_color), Bishop.new(team_color)
    return_row[3], return_row[4] = Queen.new(team_color), King.new(team_color)
    return_row
  end

  #Pawn_row is full of individual, Unique pawns
  def pawn_row(team_color)
    return_row = []
    8.times do
      return_row << Pawn.new(team_color)
    end
    return_row
  end

  #Will set the board to a reversed version of it's self, flipped.
  def reverse
    @rows.map! do |array|
      array.reverse
    end.reverse!
  end

  #Take the data in the rows, and create an ASCII board of it.
  def table(input_row = @rows)
  end
end