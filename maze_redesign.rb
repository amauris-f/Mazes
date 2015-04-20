#This file contains the methods necessary to use the redesign method
class Maze_Redesign
	attr_reader :maze, :length, :width
	@maze_a

	def initialize(maze)
		@maze = maze
		@length = maze.length
		@width = maze.width
		@maze_a = Array.new(@length){|i| Array.new(@width) { |i| "1"}}
	end

	def reconstruct()
		reset_cells
		create_walls
		2.times do check_for_invalid end
		return @maze_a
	end
	private
	def reset_cells
		(1...length - 1).each do |row|
			(1...width - 1).each do |col|
				if row.even? && col.even?
					@maze_a.fetch(row)[col] = "1"
				else
					@maze_a.fetch(row)[col] = "0"
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
				elsif spaces.size == 4
					walls = non_borders(row, col)
					construct(row, col, walls[rand(0..3)], "1")
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
		if @maze_a.fetch(row + int)[col] == "1" then wall.push(y_val) end
		if @maze_a.fetch(row)[col + int] == "1" then wall.push(x_val) end
		return wall
	end

	def choose_sides(spaces, row, col)
		if spaces.empty?
			walls = non_borders(row, col)
			choose_side =  walls[rand(walls.size)]
			construct(row, col, choose_side, "0")
		else
			(0...3).each do |mult|
				prob = (3 - mult) * 3
				if spaces.size > 1 && rand(0...10) <= prob
					choose_side = spaces.delete_at(rand(spaces.length))
					construct(row, col, choose_side, "1")
				end
			end
		end
	end

	def construct(row, col, choose_side, w_or_s)
		case choose_side
		when 0
			@maze_a.fetch(row - 1)[col] = w_or_s
		when 1
			@maze_a.fetch(row)[col + 1] = w_or_s
		when 2
			@maze_a.fetch(row + 1)[col] = w_or_s
		else
			@maze_a.fetch(row)[col - 1] = w_or_s
		end
	end
end