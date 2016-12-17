# Chess
Hello! I built this chess as a test for my skills using Ruby, and limitations on visuals (such as only ASCII art)

This is a CMD/Terminal basic Chess, available for 2 players only. I was initially going to build a Chess playing AI, but I decided
against it in order to save myself some time to work on other projects. The game features a very basic save/load mechanic. 

In order to use this code, you will need ruby installed on your computer, as well as the Gem "terminal-table", which I used
to draw out my data structure in the cmd.

##Installation
run `gem install terminal-table` to install the required gem.

##Usage
1. Navigate to folder in cmd/terminal
2. Enter `ruby play.rb`
3. Begin playing!

![Main Menu](https://raw.githubusercontent.com/Nawn/Chess/master/chess-menu.PNG)

1. Single Player - Synonymous with "Start", sorry for the confusion
2. Load - Will check if yml file exists, if so load it. 
3. Exit - Closes the program

![Chess Turn](https://raw.githubusercontent.com/Nawn/Chess/master/chess-turn.PNG)

You will simply enter the coordinates, relative to your view to control the piece. My code will check to see if the piece can move based on it's own movement rules and then present all available choices.

![Chess Choice](https://raw.githubusercontent.com/Nawn/Chess/master/chess-choices.PNG)

You will continue back and forth, until the king has been checkmated and the game is over. 

*Thank you very much for your time*
