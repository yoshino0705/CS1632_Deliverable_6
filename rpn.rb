require_relative 'functions'
# Execution starts here

# stuff = {'name' => 'Zed', 'age' => 39, 'height' => 6 * 12 + 2}
# => {"name"=>"Zed", "age"=>39, "height"=>74}
# >> puts stuff['name']

functions = Functions.new()
if ARGV.none?
	# parse user input from command line
	end
else
	command_line = true
	functions.parse_text_file(ARGV[0])
	# parse_text_file
end