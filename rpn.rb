require_relative 'functions'
# Execution starts here

# TODO: concatenate files if more than one command line argument
# 		REPL mode
functions = Functions.new()
if ARGV.none?
	# parse user input from command line
	while(1)
		print "> "
		functions.compute_line(gets)
	end
else
	functions.parse_text_file(ARGV[0])
	# parse_text_file
end