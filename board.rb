require 'terminal-table'
require_relative 'player.rb'
require_relative 'piece.rb'

class Board
  attr_reader :rows, :players

  def initialize (input_symbol = :multiplayer)
    raise ArgumentError.new("Incorrect input") unless input_symbol.is_a? Symbol
    case input_symbol
    when :multiplayer
      @players = [Player.new, Player.new]
    when :singleplayer
      @players = [Player.new, Artificial.new]
    else
      raise ArgumentError.new("#{input_symbol.to_s} is not acceptable input")
    end
          
    @rows = new_board
  end

  private
  def new_board
    empty_row = Array.new(8, " ")
    final_row = []
    final_row[0], final_row[7] = war_row, war_row
    final_row[1], final_row[6] = pawn_row, pawn_row
    2.upto(5) do |index|
      final_row[index] = empty_row.clone
    end
    final_row
  end

  def war_row
    return_row = []
    return_row[0], return_row[7] = Rook.new, Rook.new
    return_row[1], return_row[6] = Knight.new, Knight.new
    return_row[2], return_row[5] = Bishop.new, Bishop.new
    return_row[3], return_row[4] = Queen.new, King.new
    return_row
  end

  def pawn_row
    return_row = []
    8.times do
      return_row << Pawn.new
    end
    return_row
  end

  def empty_board
    empty_row = Array.new(8, " ")
    rows = []

    8.downto(1) do |number|
      rows << [number] + empty_row.clone
      rows << :separator
    end

    rows << ([" "] + Array("A".."H"))

    Terminal::Table.new :rows => rows
  end
end