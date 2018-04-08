# CS1632 Deliverable 6
# Wei-Hao Chen
# Nick Sallinger
# a class designed to evaluate RPN++
require_relative 'utilities'

class RPN
  attr_accessor :variables, :line_num, :result, :error
  def initialize(mode = 'REPL')
    @mode = mode
    @error = { 'bool' => false, 'val' => 0 }
    @operands = []
    @result = 0
    @variables = {}
    @line_num = 1
  end

  def calculate(expression)
    tokens = expression.split
    if tokens.empty?
      # blank lines should be ignored
      return 0
    end
    return execute_keywords(tokens.drop(1), tokens[0].upcase)\
    if (string? tokens[0]) && (!alphabetical? tokens[0])
    @operands = []
    compute_lines tokens
  end

  def compute_lines(tokens)
    tokens.each do |t|
      case t
      when /\d/
        @operands.push(t.to_f)
      else
        handle_other_values t
        return @error['val'] if @error['bool']
      end
    end
    update_result
  end

  def handle_other_values(token)
    if alphabetical? token
      if @variables.keys.include? token.upcase
        @operands.push(@variables[token.upcase])
      else
        puts "Line #{@line_num}: Variable #{token} is not initialized"
        @error = { 'bool' => true, 'val' => 1 }
      end
    elsif @operands.length >= 2
      if not_operator? token
        puts "Line #{@line_num}: Unknown operator #{token}"
        @error = { 'bool' => true, 'val' => 5 }
      end
      operands = @operands.pop(2)
      begin
        @operands.push(operands[0].send(token.to_s, operands[1]))
      rescue NoMethodError
        puts "Line #{@line_num}: Could not evaluate expression"
        @error = { 'bool' => true, 'val' => 5 }
      end
    else
      puts "Line #{@line_num}: Operator #{token} applied to empty stack"
      @error = { 'bool' => true, 'val' => 2 }
    end
  end

  def update_result
    if @operands.length == 1
      format_result @operands[0]
      puts @result if @mode.casecmp('REPL').zero?
    else
      puts "Line #{@line_num}: #{@operands.length} elements in stack \
after evaluation"
      @error = { 'bool' => true, 'val' => 3 }
    end
  end

  def execute_keywords(tokens, keyword)
    exit if keyword.casecmp('QUIT').zero?
    if keyword.casecmp('LET').zero?
      let tokens
    elsif keyword.casecmp('PRINT').zero?
      compute_lines tokens
      puts @result if !@mode.casecmp('REPL').zero? && !@error['bool']
    else
      puts "Line #{@line_num}: Unknown keyword #{keyword}"
      @error = { 'bool' => true, 'val' => 4 }
    end
  end

  def let(tokens)
    @error = let_err_check tokens, @line_num
    return @error['val'] if @error['bool']
    compute_lines tokens.drop(1)
    @variables[tokens[0].upcase] = @result unless @result.nil?
  end

  def format_result(result)
    same = result.to_i == result.to_f
    @result = result.to_f
    @result = result.to_i if same
  end
end
