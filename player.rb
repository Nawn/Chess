class Player
  attr_reader :team_color, :board

  def self.player_input(input_string)
  	exit if input_string.downcase == "exit"
  	potential_backs = %w(return back select)
  	raise StandardError.new("\n\nReturning to Piece select\n\n") if potential_backs.any? {|back_string| back_string == input_string.downcase}
  	input_string.gsub(/\s+/, "").upcase
  end

  def self.coord_string(input_string)
    raise ArgumentError.new("Input must be String") unless input_string.is_a? String
    input_string = Player.player_input(input_string)
    raise ArgumentError.new("Input incorrect. Example: C4, B2, A3, etc.") unless input_string =~ /[A-H][1-8]/

    [8-input_string[1].to_i, input_string[0].ord - 65]
  end

  def initialize(team_sym=nil, host_board=nil)
    t = team_sym.is_a? Symbol #Boolean
    b = host_board.is_a? Board #Boolean
    #Raise an Error unless both both have been set correctly
    raise ArgumentError.new("Requires team_color Symbol, and Board reference") unless t && b
    @team_color = team_sym
    @board = host_board
  end

  def turn
  	begin
  		puts "\n\n IT IS NOW #{@team_color.upcase}'S TURN\n\n"
	  	@board.display
	  	puts "Please input the coordinates of piece to grab"
	  	start_coord = Player.player_input(gets.chomp)
	  	start_piece = select(start_coord)
	  	#def moves(input_rows, start_pos, distance = @distance, display = true)
      moves = start_piece.moves(@board.rows, start_coord)
      
      raise StandardError.new("\n\nNo moves available for piece at #{start_coord}, returning to Piece select\n\n".upcase) if moves.empty?
      acceptable_pos = ""
      moves.each {|coord| acceptable_pos += "\t#{coord}\n"}
      puts "You may move piece to:\n#{acceptable_pos}"
      puts "Please enter destination coordinates"
      destination_coord = Player.player_input(gets.chomp)
      raise ArgumentError.new("Destination is invalid") unless moves.include?(destination_coord)

      move(start_coord, destination_coord)
    rescue StandardError => m
      puts "#{m}"
      retry
    end
  end

  def select(input_string)
    piece = @board.select(input_string)
    raise StandardError.new("Space is empty") if piece == " "
    raise StandardError.new("Not your piece") unless piece.team_color == @team_color
    piece
  end

  def move(start, destination, board_array = @board.rows)
    start_piece = select(start)
    #def moves(input_rows, start_pos, distance = @distance, display = true)

    start_row, start_pos = Player.coord_string(start)
    dest_row, dest_pos = Player.coord_string(destination)
    board_array[start_row][start_pos] = " "
    board_array[dest_row][dest_pos] = start_piece
    start_piece.move(destination)
  end
end