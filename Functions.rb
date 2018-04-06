class Functions

#TODO: Error codes

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
		#puts filename
		File.open(filename).each do |line|
			@text_file_array.push(line)
			compute_line(line)
		end
	end

	def compute_line(line)
		#puts "> " + line
		split_line = line.split
		if split_line.include?('LET') && split_line.index('LET') > 0
			puts "error in command"
			#quit if reading in file
		elsif split_line.include?('LET') && split_line.index('LET') > 0
			puts "error in command"
			#quit if reading in file
		elsif split_line.include?('LET') && split_line.index('LET') > 0
			puts "error in command"
			#quit if reading in file
		end
				
		split_line.each do |command|
			if command.eql? "LET"
				let_index = line.index('LET')
				if(let_index+3).nil?
					assign(split_line[let_index+1],split_line[let_index+2])
				else
					assign(split_line[let_index+1],split_line[let_index+2],split_line[let_index+3],split_line[let_index+4])
				end

			elsif command.eql? "PRINT"
				print_index = line.index('PRINT')
				if !["+","-","/","*"].include?(split_line[print_index+3])
					print_command(split_line[print_index+1],nil,nil)
				else
					print_command(split_line[print_index+1], split_line[print_index+2], split_line[print_index+3])
				end
			elsif command.eql? "QUIT"
				quit_command
			else
				#ERRORS FOR UNKNOWN KEYWORKDS
			end
		end
	end

	def quit_command
		exit
	end

	def assign(first,second,third,operator)
		if operator.nil?
			@variables[first] = second
		else
			if @variables.include?(second)
				second = @variables[second]
			end
			if @variables.include?(third)
				third = @variables[third]
			end

			if operator.eql?("+")
				@variables[first] = second.to_i + third.to_i
			elsif operator.eql?("-")
				@variables[first] = second.to_i + third.to_i
			elsif operator.eql?("*")
				@variables[first] = second.to_i * third.to_i
			elsif operator.eql?("/")
				@variables[first] = second.to_i / third.to_i
			end
		end

		puts @variables
			
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

		if operator.nil?
			puts first_value
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
