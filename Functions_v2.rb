class RPN
  attr_accessor :mode, :variables, :line_num, :result
  def initialize
  	@mode = 'REPL'
    @operands = []
    @result = 0
    @variables = {}
    @line_num = 1
  end

  def calculate expression
    tokens = expression.split
    if tokens.length < 1
      puts "Line #{@line_num}: Expression too short"
      return 5
    end
    if (string? tokens[0]) && (not alphabetical? tokens[0])
      return execute_keywords(tokens.drop(1), tokens[0].upcase)
    else
      return evaluate tokens
    end
  end

  def evaluate tokens
  	@operands = []
    tokens.each do |t|
      case t
        when /\d/
          @operands.push(t.to_f)          

        else
          if [*'a'..'z', *'A'..'Z'].include? t
          	if @variables.keys.include? t.upcase
              @operands.push(@variables[t.upcase])
            else
          	  puts "Line #{@line_num}: Variable #{t} is not initialized"
          	  return 1
            end

          elsif @operands.length >= 2
            operands = @operands.pop(2)
            begin
          	  @operands.push(operands[0].send(t.to_s, operands[1]))
            rescue
          	  puts "Line #{@line_num}: Could not evaluate expression"
          	  return 5
            end
          else
            puts "Line #{@line_num}: Operator #{t} applied to empty stack"
            return 2
          end
      end
    end

    if @operands.length == 1
      @result = @operands[0]      
      puts @result
      return 0
    else
      puts "Line #{@line_num}: #{@operands.length} elements in stack after evaluation"
      @result = nil
      return 3
    end
  end

  def execute_keywords(tokens, keyword)
    case keyword 
      when 'LET'
        let(tokens)
      when 'PRINT'
      	if @mode == 'REPL'
        	evaluate tokens
        else
        	evaluate tokens
        	puts @result
        end        
      when 'QUIT'
        exit
      else
      	puts "Line #{@line_num}: Unknown keyword #{keyword}"
      	return 4
    end
  end

  def let(tokens)
    if tokens.length < 1
      puts "Line #{@line_num}: Variable name missing"
      return 5
    elsif tokens.length == 1
      puts "Line #{@line_num}: Value missing"
      return 5
    elsif not alphabetical? tokens[0].upcase
      puts "Line #{@line_num}: Invalid variable name"
      return 5
    else
      evaluate tokens.drop(1)
      if not @result.nil?
        @variables[tokens[0].upcase] = @result
      end
    end

  end

  def alphabetical? s
    ('A'..'Z').to_a.include? s.upcase
  end

  def string? s
  	s.to_i.to_s != s
  end
end
