require_relative 'Functions_v2'

if ARGV.none?	
	rpn = RPN.new 'REPL'
	while true
		print "> "
		rpn.calculate gets
		rpn.line_num += 1
	end
else
	rpn = RPN.new 'FILE'
	ARGV.each do |path|
		#puts "doing #{path}"
	    if not File.exist? path
	    	puts "#{path} does not exist"
	    	exit
	    end
	    rpn.line_num = 1
	    File.readlines(path).each do |line|
	    	err = rpn.calculate line
	    	if rpn.error
	    		puts "exited with code #{err}"
	    		exit err
	    	end

	    	rpn.line_num += 1
	    end
		
	end
end