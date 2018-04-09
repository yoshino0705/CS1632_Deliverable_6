# CS1632 Deliverable 6
# Wei-Hao Chen
# Nick Sallinger
# methods for helping evaluation of RPN++

def alphabetical?(str)
  ('A'..'Z').to_a.include? str.upcase
end

def string?(str)
  str.to_i.to_s != str
end

def let_err_check(tokens, line_num)
  if tokens.empty?
    puts "Line #{line_num}: Variable name missing"
    return { 'bool' => true, 'val' => 5 }
  end
  let_syntax_err_check tokens, line_num
end

def let_syntax_err_check(tokens, line_num)
  alpha = alphabetical? tokens[0].upcase
  if tokens.length == 1 && alpha
    puts "Line #{line_num}: Value missing"
    return { 'bool' => true, 'val' => 5 }
  elsif !alpha
    puts "Line #{line_num}: Invalid variable name #{tokens[0]}"
    return { 'bool' => true, 'val' => 5 }
  end
  { 'bool' => false, 'val' => 0 }
end

def operator?(token)
  %w[+ - * /].include? token
end

def not_operator?(token)
  !%w[+ - * /].include? token
end
