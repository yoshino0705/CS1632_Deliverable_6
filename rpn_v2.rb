class RPN
  attr_accessor :operands, :variables, :line_num
  def initialize
    @keywords = ['LET', 'PRINT', 'QUIT']
    @operators = ['+', '-', '*', '/']
    @operands = []
    @variables = {}
    @line_num = 0
  end

  def calculate expression
    tokens = expression.split
    if tokens.length < 1
      puts "Line #{@line_num}: Expression too short"
    end
    if @keywords.include? tokens[0].upcase
      execute_keywords(tokens.drop(1), tokens[0].upcase)
    else
      evaluate tokens
    end
  end

  def evaluate tokens
    tokens.each do |t|
      puts "Evaluating #{t}..."
      case t
        when /\d/
          @operands.push(t.to_f)
        else
          if @operands.length >= 2
            operands = @operands.pop(2)
          else
            puts "Line #{@line_num}: Operator #{t} applied to empty stack"
            next
          end
          begin
          	@operands.push(operands[0].send(t.to_s, operands[1]))
          rescue
          	puts "Line #{@line_num}: Unknown operator #{t}"
          end
      end
    end
    nil
  end

  def execute_keywords(tokens, keyword)
    case keyword 
      when 'LET'
        let(tokens)
      when 'PRINT'
        evaluate tokens
        puts @operands[0]
      when 'QUIT'
        do_quit(tokens)
      else
      	puts "Line #{@line_num}: Unknown keyword"
    end
  end

  def let(tokens)
    if tokens.length < 1
      puts "Line #{@line_num}: Variable name missing"
    elsif tokens.length > 1 && tokens.length < 3 
    	
    elsif not ('A'..'Z').to_a.include? tokens[0].upcase
      puts "Line #{@line_num}: Invalid variable name"
    else
      @variables[tokens[0].upcase] = evaluate tokens.drop(1)
    end

  end

  def do_quit(tokens)
    if tokens.length > 0
      puts "Line #{@line_num}: Redundant trailing values"
  end
end
