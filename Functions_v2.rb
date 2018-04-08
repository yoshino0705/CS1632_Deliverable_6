class RPN
  attr_accessor :operands, :variables, :line_num, :result
  def initialize
    @keywords = ['LET', 'PRINT', 'QUIT']
    @operands = []
    @result = 0
    @variables = {}
    @line_num = 0
  end

  def calculate expression
    tokens = expression.split
    if tokens.length < 1
      puts "Line #{@line_num}: Expression too short"
      return
    end
    if (string? tokens[0]) && (not alphabetical? tokens[0])
      execute_keywords(tokens.drop(1), tokens[0].upcase)
    else
      evaluate tokens
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
          	  return
            end

          elsif @operands.length >= 2
            operands = @operands.pop(2)
            begin
          	  @operands.push(operands[0].send(t.to_s, operands[1]))
            rescue
          	  puts "Line #{@line_num}: Could not evaluate expression"
          	  return
            end
          else
            puts "Line #{@line_num}: Operator #{t} applied to empty stack"
            return
          end
      end
    end

    if @operands.length == 1
      @result = @operands[0]      
      puts @result
    else
      puts "Line #{@line_num}: #{@operands.length} elements in stack after evaluation"
      @result = nil
    end
  end

  def execute_keywords(tokens, keyword)
    case keyword 
      when 'LET'
        let(tokens)
      when 'PRINT'
        evaluate tokens
        #puts @result
      when 'QUIT'
        exit
      else
      	puts "Line #{@line_num}: Unknown keyword #{keyword}"
    end
  end

  def let(tokens)
    if tokens.length < 1
      puts "Line #{@line_num}: Variable name missing"
    elsif tokens.length == 1
      puts "Line #{@line_num}: Value missing"
    elsif not alphabetical? tokens[0].upcase
      puts "Line #{@line_num}: Invalid variable name"
    else
      evaluate tokens.drop(1)
      @variables[tokens[0].upcase] = @result
    end

  end

  def alphabetical? s
    ('A'..'Z').to_a.include? s.upcase
  end

  def string? s
  	s.to_i.to_s != s
  end
end
