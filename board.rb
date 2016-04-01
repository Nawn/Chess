require 'terminal-table'
require_relative 'player.rb'
require_relative 'piece.rb'

class Board
  attr_reader :rows, :players

  def initialize (input_symbol = :multiplayer)
    raise ArgumentError.new("Incorrect input") unless input_symbol.is_a? Symbol
    case input_symbol
    when :multiplayer
      @players = [Player.new(:white, self), Player.new(:black, self)]
    when :singleplayer
      @players = [Player.new(:white, self), Artificial.new(:black, self)]
    else
      raise ArgumentError.new("#{input_symbol.to_s} is not acceptable input")
    end
          
    @rows = new_board
  end

  def display
    puts table()
  end

  private
  def new_board
    empty_row = Array.new(8, " ")
    final_row = []
    final_row[0], final_row[7] = war_row(@players[1].team_color), war_row(@players[0].team_color)
    final_row[1], final_row[6] = pawn_row(@players[1].team_color), pawn_row(@players[0].team_color)
    2.upto(5) do |index|
      final_row[index] = empty_row.clone
    end
    final_row
  end

  def war_row(team_color)
    return_row = []
    return_row[0], return_row[7] = Rook.new(team_color), Rook.new(team_color)
    return_row[1], return_row[6] = Knight.new(team_color), Knight.new(team_color)
    return_row[2], return_row[5] = Bishop.new(team_color), Bishop.new(team_color)
    return_row[3], return_row[4] = Queen.new(team_color), King.new(team_color)
    return_row
  end

  def pawn_row(team_color)
    return_row = []
    8.times do
      return_row << Pawn.new(team_color)
    end
    return_row
  end

  def table
    rows = []
    temp_rows = @rows.map { |e| e.map {|i| i.display if i.is_a? Piece } }
    8.times do |number|
      rows << [8-number] + temp_rows[number]
      rows << :separator
    end
    rows << ([" "] + Array("A".."H"))

    Terminal::Table.new :rows => rows
  end
end