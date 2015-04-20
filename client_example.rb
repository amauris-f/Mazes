require './mazes.rb'
require './maze_extend.rb'
require './maze_redesign.rb'

maze_test = Maze.new(4,4)
maze_test.load("111111111100010001111010101100010101101110101100000101111011101100000101111111111")
puts "DISPLAYING 4 BY 4 MAZE"
puts maze_test.display
maze_test.redesign()
puts "DISPLAYING REDESIGNED MAZE"
puts maze_test.display
puts "DISPLAYING TRACE BETWEEN TWO CELLS"
puts maze_test.trace(:begX=>0, :begY=>0, :endX=>3, :endY=>3)


maze_test = Maze.new(4,5)
maze_test.redesign()
puts "DISPLAYING 5 BY 4 MAZE"
puts maze_test.display
#maze_test.load("111111111100010001111010101100010101101110101100000101111011101101000101101010101101010101111111111")
puts "DISPLAYING TRACE BETWEEN TWO CELLS (0,0) and (3,3)"
puts maze_test.trace(:begX=>0, :begY=>0, :endX=>3, :endY=>3)