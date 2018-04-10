require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require_relative 'functions'
require_relative 'utilities'

class RPN_test < Minitest::Test
  def setup
    @rpn_repl = RPN.new 'REPL'
    @rpn_file = RPN.new 'FILE'
  end

  ## UNIT TEST FOR let

  def test_let_valid_syntax
    @rpn_repl.error['bool'] = false
    syntax = 'p 90'.split
    @rpn_repl.let syntax
    assert_equal @rpn_repl.variables['P'], 90
    assert_equal @rpn_repl.error['bool'], false
  end

  def test_let_invalid_syntax
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []
    syntax = 'p chan'.split
    @rpn_repl.let syntax
    assert_equal @rpn_repl.variables['P'], nil
    assert_equal @rpn_repl.error['bool'], true
  end

  ## UNIT TEST FOR execute_keywords

  def test_execute_keywords_let_valid_var_name
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []
    syntax = 'let p 9 10 *'.split
    @rpn_repl.execute_keywords syntax.drop(1), syntax[0]
    assert_equal @rpn_repl.variables['P'], 90
    assert_equal @rpn_repl.error['bool'], false
  end

  def test_execute_keywords_let_invalid_var_name
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []
    syntax = 'let p-chan 9 10 *'.split    
    assert_output(/Invalid variable name/){ @rpn_repl.execute_keywords syntax.drop(1), syntax[0] }
    assert_nil @rpn_repl.variables['P']
  end

  def test_execute_keywords_print_in_repl_mode
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []
    syntax = 'print 5 5 *'.split
    assert_output(/25/){ @rpn_repl.execute_keywords syntax.drop(1), syntax[0] }
    assert_equal @rpn_repl.result, 25
  end

  def test_execute_keywords_print_in_file_mode
    @rpn_file.error['bool'] = false
    @rpn_file.operands = []
    syntax = 'print 5 5 *'.split
    assert_output(/25/){ @rpn_file.execute_keywords syntax.drop(1), syntax[0] }
    assert_equal @rpn_file.result, 25
  end

  def test_execute_keywords_unknown_keyword
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []
    syntax = 'what is 5 5 *'.split
    assert_output(/Unknown keyword/){ @rpn_repl.execute_keywords syntax.drop(1), syntax[0] }
    assert_equal @rpn_repl.error['val'], 4
  end
  
  ## UNIT TEST FOR print_in_file_mode?
  def test_print_in_file_mode_repl
    @rpn_repl.error['bool'] = false
    assert_equal @rpn_repl.print_in_file_mode?, false
  end

  def test_print_in_file_mode_file
    @rpn_file.error['bool'] = false
    assert_equal @rpn_file.print_in_file_mode?, true
  end

  ## UNIT TEST FOR update_result
  def test_update_result_valid
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = [666]
    @rpn_repl.update_result
    assert_equal @rpn_repl.result, 666
    assert_equal @rpn_repl.error['bool'], false
  end

  def test_update_result_error
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = [666, 777]
    assert_output(/elements in stack/){ @rpn_repl.update_result }
    assert_equal @rpn_repl.error['val'], 3
  end

  ## UNIT TEST FOR handle_other_values
  def test_handle_other_values_variable_exists
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []
    @rpn_repl.variables = {'A' => 5}
    @rpn_repl.handle_other_values 'a'
    assert_includes @rpn_repl.operands, 5
  end

  def test_handle_other_values_variable_doesnt_exists
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []    
    assert_output(/is not initialized/){ @rpn_repl.handle_other_values 'a' }
    assert_equal @rpn_repl.error['val'], 1
  end

  def test_handle_other_values_valid_eval
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = [9, 10]
    @rpn_repl.handle_other_values '*'
    assert_includes @rpn_repl.operands, 90
    assert_equal @rpn_repl.error['bool'], false
  end

  def test_handle_other_values_empty_stack
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []
    assert_output(/empty stack/){ @rpn_repl.handle_other_values '+' }
    assert_equal @rpn_repl.error['val'], 2
  end

  def test_handle_other_values_unknown_operator
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = [9, 10]
    assert_output(/Unknown operator/){ @rpn_repl.handle_other_values '**' }
    assert_equal @rpn_repl.error['val'], 5
  end

  def test_handle_other_values_zero_division
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = [9, 0]
    assert_output(/Divided by zero/){ @rpn_repl.handle_other_values '/' }
    assert_equal @rpn_repl.error['val'], 5
  end

  ## UNIT TEST FOR handle_token
  def test_handle_token
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []
    token = '666'
    @rpn_repl.handle_token token
    assert_includes @rpn_repl.operands, 666
    assert_equal @rpn_repl.error['bool'], false
  end

  ## UNIT TEST FOR compute_lines
  def test_compute_lines
    @rpn_repl.error['bool'] = false
    @rpn_repl.compute_lines '3 3 * 5 2 * *'.split
    assert_includes @rpn_repl.operands, 90
    assert_equal @rpn_repl.error['bool'], false
  end

  ## UNIT TEST FOR calculate
  def test_calculate
    @rpn_repl.error['bool'] = false
    @rpn_repl.calculate 'let p 3 3 * 5 2 * *'
    assert_includes @rpn_repl.variables.keys, 'P'
    assert_equal @rpn_repl.result, 90
  end

  #################################
  #################################
  #### TEST CASES FOR utilities ###
  #################################
  #################################
  
  # UNIT TEST FOR alphabetical?
  def test_alphabetical_true
    assert_equal (alphabetical? 'p'), true
  end

  def test_alphabetical_false
    assert_equal (alphabetical? '90'), false
  end

  # UNIT TEST FOR string?
  def test_string_true
    assert_equal (string? 'p-chan'), true
  end

  def test_string_false
    assert_equal (string? '555'), false
  end

  # UNIT TEST FOR let_err_check
  def test_let_err_check
    assert_output(/Variable name missing/){ let_err_check '', 1 }
  end

  # UNIT TEST FOR let_syntax_err_check
  def test_let_syntax_err_check_value_missing
    assert_output(/Value missing/){ let_syntax_err_check 'a'.split, 1}
  end

  def test_let_syntax_err_check_invalid_var_name
    assert_output(/Invalid variable name/){ let_syntax_err_check '5'.split, 1}
  end

  # UNIT TEST FOR operator?
  def test_operator_true
    assert_equal (operator? '*'), true
  end

  def test_operator_false
    assert_equal (operator? '**'), false
  end

  # UNIT TEST FOR not_operator?
  def test_not_operator_true
    assert_equal (not_operator? '**'), true
  end

  def test_not_operator_false
    assert_equal (not_operator? '*'), false
  end

end