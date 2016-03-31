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
    war_row = Array.new(8, Piece.new)
    final_row = []

    2.times do
      final_row << war_row.clone
    end

    4.times do
      final_row << empty_row.clone
    end

    2.times do 
      final_row << war_row.clone
    end

    final_row
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