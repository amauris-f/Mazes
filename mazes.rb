require './maze_extend.rb'
require './maze_redesign.rb'
gem 'minitest'

class Maze
	attr_reader :columns, :rows, :maze_s, :width, :length, :maze_a
	@maze_check
	@maze_s = nil
	@maze_a
	@maze_display
	@visited
	@all_paths

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
		validate_maze = @maze_check.validate(maze_s)
		if validate_maze != true
			@maze_s = nil
			return puts validate_maze
		end
	end

	def display
		check = @maze_check.loaded?
		if check != true then return check end
		print @maze_display
	end 

	def draw_maze
		@maze_display = ""
		draw_borders
		draw_positions
		draw_borders
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

	def draw_borders
		(1..width).each do |i|
			if i.even?
				@maze_display += "-"
			else 
				@maze_display += "+"
			end
		end
		@maze_display += "\n"
	end

	def draw_positions
		(1...length - 1).each do |row_ind|
			(0... width).each do |col_ind|
				determine_symbol(row_ind, col_ind)
			end
			@maze_display += "\n"
		end
	end

	def determine_symbol(row_ind, col_ind)
		if maze_a.fetch(row_ind)[col_ind] == "0"
			@maze_display += " "
		elsif row_ind.even? && !col_ind.even?
			@maze_display += "-"
		elsif row_ind.even? && col_ind.even?
			@maze_display += "+"
		else 
			@maze_display += "|"
		end
	end
		def solve(params = {})
		check = @maze_check.loaded?
		if check != true then return check end
		result = traverse(params)
		if result
			puts "There is a path between these two points. Use trace to look at the steps."
		else
			puts "Unsolvable: There is no path between these two points."
		end
	end

	def trace(params = {})
		check = @maze_check.loaded?
		if check != true then return check end
		traceable = traverse(params)
		if traceable
			steps_taken
		else
			puts "Untraceable: There is no path between these two points."
		end
	end

	def steps_taken
		mvmnt = ["Right", "Down", "Left", "Up"]
		stack = Array.new()
		add_to_stack(stack)
		(stack.size).times do |step|
			cell = stack.pop()
			puts "#{step+1}. From cell: #{cell}, Move #{mvmnt[cell.dir]} to #{cell.next}."
		end
	end

	def add_to_stack(stack)
		transition = @all_paths.pop()
		while transition.prev_step
				transition = transition.prev_step
				stack.push(transition)
		end
	end

	def traverse(params)
		beg_point = Point.new(params[:begX], params[:begY])
		end_point = Point.new(params[:endX], params[:endY])
		@all_paths = Array.new()
		@visited = Array.new()
		@all_paths.push(beg_point)
		while !@all_paths.include?(end_point)
			if @all_paths.empty? then return false end
			trans = @all_paths.shift()
			if !@visited.include?(trans) then one_step_moves(trans) end
		end
		return true
	end

	def one_step_moves(trans)
		@visited.push(trans)
		(0..3).each do |dir|
			if valid_move?(trans, dir)
				add_position(trans, dir)
			end
		end
	end

	def add_position(trans, dir)
		x_move = [1, 0, -1, 0]
		y_move = [0, 1, 0, -1]
		new_x = trans.x + x_move[dir]
		new_y = trans.y + y_move[dir]
		new_pos = Point.new(new_x, new_y)
		marked?(trans, dir, new_pos)
	end

	def marked?(trans, dir, new_pos)
		if !@visited.include?(new_pos)
			new_pos.prev_step = trans
			trans.next = new_pos
			trans.dir = dir
			@all_paths.push(new_pos)
		end
	end

	def valid_move?(trans, dir)
			col_ary = trans.x * 2 + 1
			row_ary = trans.y * 2 + 1
			case dir
			when 0
				if maze_a.fetch(row_ary)[col_ary + 1] == "0" then return true end
			when 1
				if maze_a.fetch(row_ary + 1)[col_ary] == "0" then return true end
			when 2
				if maze_a.fetch(row_ary)[col_ary - 1] == "0" then return true end
			when 3
				if maze_a.fetch(row_ary - 1)[col_ary] == "0" then return true end
			else
				return false
			end
	end
		def redesign()
		@maze_a = Array.new(length){|i| Array.new(width) { |i| "1"}}
		reset_cells
		create_walls
		check_for_invalid
		draw_maze
	end
	private
	def reset_cells
		(1...length - 1).each do |row|
			(1...width - 1).each do |col|
				if row.even? && col.even?
					maze_a.fetch(row)[col] = "1"
				else
					maze_a.fetch(row)[col] = "0"
				end
			end
		end
	end

	def create_walls
		(1...length - 1).step(2) do |row|
			(1...width).step(2) do |col|
				spaces = adj_walls(row, col)
				choose_sides(spaces, row, col)
			end
		end
	end

	def check_for_invalid
		(1...length - 1).step(2) do |row|
			(1...width).step(2) do |col|
				spaces = adj_walls(row, col)
				if spaces.empty?
					walls = non_borders(row, col)
					construct(row, col, walls[rand(walls.size)], "0")
				end
			end
		end
	end

	def non_borders(row, col) 
		walls = [0, 1, 2, 3]
		walls = exclude_top_bottom(col, walls)
		walls =exclude_maze_sides(row, walls)
		return walls
	end

	def exclude_maze_sides(row, walls)
		if row + 1 == length - 1
			walls.delete(2)
		elsif row - 1 == 0
			walls.delete(0)
		end
		return walls
	end 

	def exclude_top_bottom(col, walls)
		if col - 1 == 0
			walls.delete(3)
		elsif col + 1 == width - 1
			walls.delete(1)
		end
		return walls
	end

	def adj_walls(row, col)
		wall = Array.new()
		sides = [0, 1, 2, 3]
		wall = find_walls(row, col, 1, 1, wall)
		wall = find_walls(row, col, -1, 0, wall)
		spaces_left = sides - wall
		return spaces_left
	end

	def find_walls(row, col, int, dir, wall)
		x_val = 3 - 2 * (dir)
		y_val = 2 * dir
		if maze_a.fetch(row + int)[col] == "1" then wall.push(y_val) end
		if maze_a.fetch(row)[col + int] == "1" then wall.push(x_val) end
		return wall
	end

	def choose_sides(spaces, row, col)
		if spaces.empty?
			walls = non_borders(row, col)
			construct(row, col, walls[rand(walls.size)], "0")
			# choose_side = rand(0..3)
			# construct(row,col, choose_side, "0")
		else
			(0...3).each do |mult|
				prob = (3 - mult) * 3
				if spaces.size > 2 && rand(0...10) >= prob
					choose_side = spaces.delete_at(rand(spaces.length))
					construct(row, col, choose_side, "1")
				end
			end
		end
	end

	def construct(row, col, choose_side, w_or_s)
		case choose_side
		when 0
			maze_a.fetch(row - 1)[col] = w_or_s
		when 1
			maze_a.fetch(row)[col + 1] = w_or_s
		when 2
			maze_a.fetch(row + 1)[col] = w_or_s
		else
			maze_a.fetch(row)[col - 1] = w_or_s
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
		check_misplaced(maze_print)
		cell_check
	end

	def check_misplaced(maze_print)
		count = 1
		maze_print.each_line do |row|
			(maze.columns).times do |index|
				if row[index] == "|" && !index.even?
					return """ERROR: You have a wall in the place of a cell. In every row, a wall
can only be placed in an even index, while all odd indexes are meant for cell spots. Load unsuccessful."""
				elsif !count.even? && index.even?
					if row[index] == " "
						return """ERROR: You have a space on an index where only walls are allowed. Load unsuccessful."""
					end
				end 
			end
			count += 1
		end		
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

class Point
	attr_reader :x, :y
	attr_accessor :prev_step, :dir, :next

	def initialize(x, y)
		@x = x
		@y = y
	end

	def ==(other_point)
		self.x == other_point.x && self.y == other_point.y
	end

	def to_s
			return "(#{x} , #{y})"
	end
end



 maze_test = Maze.new(4,4)
 maze_test.load("111111111100010001111010101100010101101110101100000101111011101100000101111111111")
 maze_test.display
 #maze_test.trace(:begX=>0, :begY=>0, :endX=>3, :endY=>3)
 maze_test.redesign()
 maze_test.display

 # maze_test = Maze.new(4,5)
 # maze_test.load("111111111100010001111010101100010101101110101100000101111011101101000101101010101101010101111111111")
 # puts maze_test.display
 # #maze_test.trace(:begX=>0, :begY=>0, :endX=>3, :endY=>3)
 # maze_test.redesign()