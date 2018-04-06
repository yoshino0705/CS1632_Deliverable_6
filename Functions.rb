class Functions

# stuff = {'name' => 'Zed', 'age' => 39, 'height' => 6 * 12 + 2}
# => {"name"=>"Zed", "age"=>39, "height"=>74}
# >> puts stuff['name']

@variables
@text_file_array

	def initialize()
		@text_file_array = Array.new
		@variables = {}
	end

	def parse_input(user_input)
		#puts "Parse line"
		puts user_input
		if user_input.match(/^LET/)
			puts "LET"
		elsif user_input.match(/^QUIT/)
			puts "QUIT"
		elsif user_input.match(/^PRINT/) 
			puts 'PRINT'
		end
	end

	def parse_text_file(filename)
		#parse a command line argument file
		puts filename
		File.open(filename).each do |line|
			@text_file_array.push(line)
			compute_line(line)
		end
	end

	def compute_line(line)
		puts "> " + line
		split_line = line.split
		split_line.each do |command|
			if command.eql? "LET"
				let_index = line.index('LET')
				assign(split_line[let_index+1],split_line[let_index+2])
			elsif command.eql? "PRINT"
				print_index = line.index('PRINT')
				if !["+","-","/","*"].include?(split_line[print_index+3])
					print_command(split_line[print_index+1],nil,nil)
				else
					print_command(split_line[print_index+1], split_line[print_index+2], split_line[print_index+3])
				end
			elsif command.eql? "QUIT"
				quit_index = line.index('QUIT')
			else
			end
		end
	end

	def end?
		#line contains QUIT or end of file
	end

	def assign(first,second)
		#puts 'assigning ' + first.to_s + " to " + second.to_s
		@variables[first] = second
		puts second
	end

	def print_command(first,second,operator)
		
		if @variables.include?(first)
			first_value = @variables[first].to_i
		else
			first_value = first.to_i
		end
		if @variables.include?(second)
			second_value = @variables[second].to_i
		else 
			second_value = second.to_i
		end

		#puts operator

		# if first.is_a?(Integer)
		# 	puts 'integer'
		# else
		# 	puts 'not an integer'
		# end


		if operator.nil?
			puts first
		elsif operator.eql? "+"
			output = first_value + second_value
			puts output
		elsif operator.eql? "-"
			output = first_value - second_value
			puts output
		elsif operator.eql? "*"
			output = first_value * second_value
			puts output
		elsif operator.eql? "/"
			output = first_value / second_value
			puts output
		end

	end

end
