require_relative 'board.rb'

def menu_select(input)
  player_input = input.gsub(/\s+/, "")
  exit if player_input == "exit"
  player_input[0].to_i
end

puts "Thanks for playing Chess!"

select = false
until select
  puts "Please select the game mode! (Enter 1, 2, 3, or 4)\n\n1. Single player\n2. Multi player\n3. Load last save\n4. Exit"

  case menu_select(gets.chomp)
  when 1
    puts "Creating board with AI..."
    board = Board.new(:singleplayer)
    select = true
  when 2
    puts "Creating Board for 2 players..."
    board = Board.new(:multiplayer)
    select = true
  when 3
    puts "Save/Load not implemented yet"
    select = true
  when 4
    exit
    select = true
  else
    puts "Input not recognized\nReturning to menu"
  end
end