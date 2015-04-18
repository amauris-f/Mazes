#http://stackoverflow.com/questions/28696109/display-extended-ascii-character-in-ruby
require './maze_extend.rb'
class Maze
	attr_reader :columns, :rows, :maze_check, :maze_s, :width, :length
	attr_reader :maze_a
	@maze_s = nil
	@maze_a
	@maze_display

	def initialize(columns, rows)
		@columns = columns
		@rows = rows
		@width = columns * 2 + 1
		@length = rows * 2 + 1
		@maze_check = Maze_Validate.new(self)
	end

	def load(maze_s)
		@maze_s = maze_s
		@maze_a = Array.new(length){Array.new(width)}
		convert_maze_to_a
		validate_maze = maze_check.validate(maze_s)
		if validate_maze != true
			@maze_s = nil
			return puts validate_maze
		end
	end

	def display
		check = maze_check.loaded?
		if check != true then return check end
		return @maze_display
	end

	def convert_maze_to_a
		position = 0
		(0...length).each do |row_ind|
			(0...width).each do |col_ind|
				maze_a.fetch(row_ind)[col_ind] = maze_s[position]
				position +=1
			end
		end
	end

	def draw_maze
		@maze_display = ""
		draw_borders
		draw_positions
		draw_borders
	end

	def draw_borders
		width.times do
			@maze_display += "-"
		end
		@maze_display += "\n"
	end

	def draw_positions
		(1...length - 1).each do |row_ind|
			(0... width).each do |col_ind|
				if maze_a.fetch(row_ind)[col_ind] == "0"
					@maze_display += " "
				elsif row_ind % 2 == 0
					@maze_display += "-"
				else
					@maze_display += "|"
				end
			end
			@maze_display += "\n"
		end
	end
end

class Maze_Validate
	attr_reader :maze

	def initialize(maze)
		@maze = maze
	end

	def validate(maze_s)
		if maze_s.size != maze.width * maze.length
			return "ERROR: With your number of columns being #{maze.columns},
and your number of rows being #{maze.rows},you should load a string with a length
of #{maze.width * maze.length}. The length of the string that you entered was
#{maze_s.length}. Load unsuccessful."
		end
		check_borders(maze_s)
	end

	def check_borders(maze_s)
		width = maze.width
		error = "ERROR: At least one of your borders has an open space.
All of the maze's borders must be closed. Load unsuccessful."
		indexed_maze = maze_s.split(//)
		maze_s.size.times do |index|
			if index < width || index > maze_s.size - width
				if indexed_maze[index] == "0" then return error end
			elsif index % width == 0 || index % width == width - 1
				if indexed_maze[index] == "0" then return error end
			end
		end
		wall_check
	end

	def wall_check
		maze_print = maze.draw_maze
		if maze_print.include?('||')
			return "ERROR: Your maze contains walls that are next to each other. Load unsuccessful."
		end
		maze_print.each_line do |row|
			(maze.columns).times do |index|
				if row[index] == "|" && index % 2 == 1
					return """ERROR: You have a wall in the place of a cell. In every row, a wall
can only be placed in an even index, while all odd indexes are meant for cell spots. Load unsuccessful."""
				end
			end
		end
		cell_check
	end

	def cell_check
		maze_a = maze.maze_a
		(1...maze.length - 1).each do |row_ind|
			(1...maze.width - 1).each do|col_ind|
				num_walls = invalid_cell(row_ind, col_ind, maze_a)
				if num_walls == 4 || num_walls == 0
					return """ERROR: One of your cells are invalid,
because it contains either 0 or 4 walls. Load unsuccessful."""
				end
			end
		end
		return true
	end

	def invalid_cell(x_val, y_val, maze_a)
		 count = 0
		 adjacent_val = [1, -1]
		 (0..1).each do |adj|
		 	if maze_a.fetch(x_val + adjacent_val[adj]).fetch(y_val) == "1" then count += 1 end
		 	if maze_a.fetch(x_val).fetch(y_val + adjacent_val[adj]) == "1" then count += 1 end
		 end
		 return count
	end

	def loaded?
		if maze.maze_s == nil
			return "ERROR: Cannot display maze because you have not loaded the maze yet."
		else
			return true
		end
	end
end



maze_test = Maze.new(4,4)
maze_test.load("111111111100010001111011101100010101101110101100000101111011101100000101111111111")
puts maze_test.display

point = Point.new(5, 6)
maze_test.trace(:begX => 0, :begY => 0, :endX =>0, :endY =>3)

maze_test = Maze.new(4,5)
maze_test.load("111111111100010001111010101100010101101110101100000101111011101101000101100010001101010101111111111")
puts maze_test.display

maze_test.trace(:begX => 0, :begY => 0, :endX =>3, :endY =>4)
