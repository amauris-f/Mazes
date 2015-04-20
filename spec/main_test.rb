gem "minitest"
require "minitest/autorun"
load './mazes.rb'

describe Maze do
	describe "when maze is initialized" do
		before do
			@maze = Maze.new(4,5)
		end
		
		it "should have the number of rows and columns" do
			@maze.columns.must_equal 4
			@maze.rows.must_equal 5
		end

		it "should have the length and width of the array representation" do
			@maze.length.must_equal 11
			@maze.width.must_equal 9
		end

		it "should not load a string of incorrect length" do 
			@maze.load("1101101101").wont_equal true
		end
	end

	describe "when maze is loaded" do
		before do
			@maze = Maze.new(4,4)
			@maze.load("111111111100010001111010101100010101101110101100000101111011101100000101111111111")
		end

		it "can display the maze" do
			@maze.display.must_equal """+-+-+-+-+
|   |   |
+-+ + + +
|   | | |
+ +-+ + +
|     | |
+-+ +-+ +
|     | |
+-+-+-+-+
"""
		end
		it "can determine if one point can reach another point" do
		  reachable_y_n = @maze.solve(:begX=>0, :begY=>0, :endX=>3, :endY=>3)
		  reachable_y_n.must_equal true
		end

		it "can trace the path between two points" do 
		  @maze.trace(:begX=>0, :begY=>0, :endX=>3, :endY=>3).must_equal true
		end
	end

	describe "when maze is redesigned" do
		before do
			@maze = Maze.new(rand(2..15), rand(2..10))
			@maze.redesign()
		end

		it "should still satisfy maze requirements" do
			@maze_check = Maze_Validate.new(@maze)
			@maze_check.validate(@maze.maze_s).must_equal true
		end
	end
end

describe Cell do 
	it "should return x and y values" do
		cell = Cell.new(5,6)
		cell.x.must_equal 5
		cell.y.must_equal 6
	end
	it "should compare cells based on x and y values" do 
		cell_1 = Cell.new(5,6)
		cell_2 = Cell.new(5,6)
		cell_3 = Cell.new(0,0)
		(cell_1 == cell_2).must_equal true
		(cell_1 == cell_3).must_equal false
	end
end