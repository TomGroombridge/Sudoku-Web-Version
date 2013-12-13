require 'sinatra' #load sinatra
require 'sinatra/partial'
require 'rack-flash'

require_relative './lib/sudoku'
require_relative './lib/cell'
require_relative './helpers/application.rb'

	set :partial_template_engine, :erb
	set :session_secret, "i'm the secret key to sign the cookie"
	enable :sessions
	use Rack::Flash

	def random_sudoku
	    # we're using 9 numbers, 1 to 9, and 72 zeros as an input
	    # it's obvious there may be no clashes as all numbers are unique
	    seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
	    sudoku = Sudoku.new(seed.join)
	    # then we solve this (really hard!) sudoku
	    sudoku.solve!
	    # and give the output to the view as an array of chars
	    sudoku.to_s.chars
	end
	
	def puzzle(sudoku)
	 numbers = sudoku.dup
	 until numbers.count(0) == 41
		 numbers[rand(0..80)] = 0
	 end
	 numbers
	end

	def box_order_to_row_order(cells)
		box_indicies = ([0,3,6,27,30,33,54,57,60].map{ |i| [i, i+1, i+2, i+9, i+10, i+11,i+18, i+19, i+20]}).flatten
		box_indicies.map{|box_index| cells[box_index]}
	end

	
	def generate_new_puzzle_if_necessary
		 return if session[:current_solution]
		 sudoku = random_sudoku
	 	 session[:solution] = sudoku
	 	 session[:puzzle] = puzzle(sudoku)
  	 session[:current_solution] = session[:puzzle]    
	end

	def prepare_to_check_solution
  	@check_solution = session[:check_solution]
  	if @check_solution 
  		flash[:notice] = "incorrect values are highlighted in yellow"
  	end
  	session[:check_solution] = nil
	end



	get '/' do
	  prepare_to_check_solution
	  generate_new_puzzle_if_necessary
	  @current_solution = session[:current_solution] || session[:puzzle]
	  @solution = session[:solution]
	  @puzzle = session[:puzzle]
	  erb :index 
	  # erb :cell
	end

post '/' do
		# inspect
		# p "HI"
		# p params["cell"]
  cells = box_order_to_row_order(params["cell"])  
  session[:current_solution] = cells.map{|value| value.to_i }.join
  session[:check_solution] = true
  redirect to("/")
end

get '/solution' do
	@current_solution = session[:solution]
	@solution = session[:solution]
	@puzzle = session[:solution] 
	erb :index 
end

	





	