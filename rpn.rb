require_relative 'functions'

def invalid_path_exit(path_name)
  puts "#{path_name} does not exist"
  exit
end

if ARGV.none?
  rpn = RPN.new 'REPL'
  loop do
    print '> '
    rpn.calculate gets
    rpn.line_num += 1
  end
else
  rpn = RPN.new 'FILE'
  ARGV.each do |path|
    invalid_path_exit path unless File.exist? path
    rpn.line_num = 1
    File.readlines(path).each do |line|
      rpn.calculate line
      exit rpn.error['val'] if rpn.error['bool']
      rpn.line_num += 1
    end
  end
end
