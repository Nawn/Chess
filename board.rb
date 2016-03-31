require 'terminal-table'
require_relative 'player.rb'

class Board
  attr_reader :table

  def initialize (input_symbol = :multiplayer)
  end

  private
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