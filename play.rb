require_relative 'board.rb'

def menu_select(input)
  player_input = input.gsub(/\s+/, "") #Cleanse input of white spaces
  exit if player_input == "exit" #Exit the game
  player_input[0].to_i #Return the first character, and make it a number
end

puts "Thanks for playing Chess!"

done = false

until done
  select = false
  until select
    puts "Please select the game mode! (Enter 1, 2, or 3)\n\n1. Single player\n2. Load last save\n3. Exit"

    case menu_select(gets.chomp)
    when 1
      puts "\n\nCreating Board for 2 players..."
      board = Board.new(:multiplayer)
      select = true
    when 2
      puts "Save/Load not implemented yet"
      select = true
    when 3
      exit
      select = true
    else
      puts "Input not recognized\nReturning to menu"
    end
  end

  until board.over?
    board.turn
  end

  puts "\n\nGame ends in Draw! STALEMATE!\n\n"if board.players[0].stalemate?
  puts "\n\nCHECKMATE! #{board.players[1].team_color.to_s.capitalize} Player wins!" if board.players[0].checkmate?
  puts "\n\nDo you wish you play again? (Anything to continue, No to quit)"
  response = gets.chomp.downcase
  done = true if response == "no" || response == "n" || response == "exit"
end

puts "Thanks for playing!"