class Maze
	@visited
	@all_paths

	def solve(params = {})
		result = traverse(params)
		if result
			puts "There is a path between these two points. Use trace to look at the steps."
		else
			puts "Unsolvable: There is no path between these two points."
		end
	end

	def trace(params = {})
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
		transition = @all_paths.pop()
		while transition.prev_step
				transition = transition.prev_step
				stack.push(transition)
		end
		(stack.size).times do |step|
			cell = stack.pop()
			puts "#{step+1}. From cell: #{cell}, Move #{mvmnt[cell.dir]} to #{cell.next}."
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
			if !@visited.include?(trans)
				one_step_moves(trans)
				@visited.push(trans)
			end
		end
		return true
	end

	def one_step_moves(trans)
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
		new_pos = Point.new(new_y, new_y)
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

	def valid_move?(trans, di)
			col_ary = trans.x * 2 + 1
			row_ary = trans.y * 2 + 1
			case di
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
