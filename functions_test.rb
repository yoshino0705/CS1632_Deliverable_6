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

  ## UNIT TEST FOR let(tokens)
  ## let() sets the variable value based on the given array
  ##
  ## VALID PARAMETER: '<VAR_NAME> <EXPRESSION>', splitted into an array
  ## VALID CASES:
  ## Valid variable names: alphabetical letters A-Z, case insensitive
  ## Ex: let p 90
  ##
  ## INVALID CASES / EDGE CASES: 
  ## invalid variable name or invalid expression
  ## Invalid variable name: let p chan
  ## Invalid expression: let p-chan 9 10 *

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

  def test_variable_case_sensitivity
    syntax1 = 'A 1234'.split
    rtrn1 = @rpn_repl.let(syntax1)
    syntax2 = 'a 1234'.split
    rtrn2 = @rpn_repl.let(syntax2)
    assert_equal(rtrn2,rtrn1)
  end

  ## UNIT TEST FOR execute_keywords(tokens, keyword)
  ## execute_keywords() handles the operations of the 3 keywords
  ## LET, QUIT, PRINT
  ## though since QUIT will also quit the test, only let and print
  ## will be tested here
  ##
  ## VALID LET SYNTAX: LET <valid variable name> <valid expression>
  ## VALID PRINT SYNTAX: PRINT <valid expression>
  ##
  ## Valid variable names: alphabetical letters A-Z, case insensitive
  ## Valid expression: valid RPN expression
  ##
  ## POSSIBLE ERRORS:
  ##   Unknown keyword: when the keyword isn't let, print, or quit
  ##     error code: 4
  ##   Invalid variable name: when the given variable name doesn't exist
  ##   in the @variable dictionary/hash
  ##     error code: 5

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

  def test_keyword_case_insensitivity
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []
    syntax1 = 'PRiNt 2 2 *'.split
    syntax2 = 'print 2 2 *'.split
    return1 = @rpn_repl.execute_keywords syntax1.drop(1), syntax1[0]
    return2 = @rpn_repl.execute_keywords syntax2.drop(1), syntax2[0]
    assert_equal(return1,return2)
  end
  
  ## UNIT TEST FOR print_in_file_mode?
  ## print_in_file_mode? 
  ##   returns true: if @mode is not 'REPL'
  ## and there is no error occurred prior to the execution of this method
  ##
  ##   returns false: if @mode is 'REPL'
  ## or there exists an error prior to the execution of this method
  ##
  ##

  def test_print_in_file_mode_repl
    @rpn_repl.error['bool'] = false
    assert_equal @rpn_repl.print_in_file_mode?, false
  end

  def test_print_in_file_mode_file
    @rpn_file.error['bool'] = false
    assert_equal @rpn_file.print_in_file_mode?, true
  end

  ## UNIT TEST FOR update_result
  ## update_result changes the value of @result
  ## based on the values inside @operands
  ##
  ## EDGE CASES: @operands has more than 1 element
  ##
  ##

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
  ## takes in a token, could be a number, variable name, or operator
  ## Valid variable names: alphabetical letters A-Z, case insensitive
  ## Valid number: any integer or floats (though will auto convert to int)
  ## Valid operator: +, -, *, /
  ##
  ## EDGE CASES:
  ## Variable doesn't exist in the @variable dictionary
  ##   returns an error 'Variable not initialized'
  ##              error code 1
  ##
  ## Given token is an operator but the stack is empty
  ##   returns an error 'operator applied to empty stack'
  ##              error code 2
  ##
  ## Given token isn't a valid operator, such as **
  ##   returns an error 'unknown operator'
  ##              error code 5
  ##
  ## Given token is the division operator, and there are two values
  ## on the stack, but the second value is 0
  ##   returns an error 'divided by zero'
  ##              error code 5
  ##

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
  ## handle_token pushes values to the stack
  ## if value is valid
  ## such as the number 666
  ## since previous tests have covered
  ## the methods handle_token will call
  ## this test is simply testing valid cases
  ##

  def test_handle_token
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []
    token = '666'
    @rpn_repl.handle_token token
    assert_includes @rpn_repl.operands, 666
    assert_equal @rpn_repl.error['bool'], false
  end

  ## UNIT TEST FOR compute_lines
  ## compute_lines calculates given expression array
  ## 
  ## since previous tests have covered
  ## the methods compute_lines will call
  ## this test is simply testing valid cases
  ##

  def test_compute_lines
    @rpn_repl.error['bool'] = false
    @rpn_repl.compute_lines '3 3 * 5 2 * *'.split
    assert_includes @rpn_repl.operands, 90
    assert_equal @rpn_repl.error['bool'], false
  end

  ## UNIT TEST FOR calculate()
  ## calculate runs the given syntax
  ## including the keywords
  ##
  ## since previous tests have covered
  ## the methods calculate() will call
  ## this test is simply testing valid cases
  ## 

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
  
  ## UNIT TEST FOR alphabetical?
  ## checks if the given string is of
  ## alphabetical letter or not
  ## case insensitive
  ##
  ## Valid values: single letter 'a' to 'z'
  ## Invalid values / EDGE CASES: none of the above
  ## 

  def test_alphabetical_true
    assert_equal (alphabetical? 'p'), true
  end

  def test_alphabetical_false
    assert_equal (alphabetical? '90'), false
  end

  ## UNIT TEST FOR string?
  ## checks if the given string is not numeric
  ## i.e. it's not just a string of numbers
  ##
  ## Valid Cases: 'ABC', 'A1B2C3'
  ## Invalid Cases / EDGE CASES: '123456789'
  ##

  def test_string_true
    assert_equal (string? 'p-chan'), true
  end

  def test_string_false
    assert_equal (string? '555'), false
  end

  ## UNIT TEST FOR let_err_check
  ## validates the expresson after the keyword LET
  ## e.g. LET a 5
  ## the 'a 5' part will be thrown into let_error_check
  ## 
  ## EDGE CASES:
  ## RPN expression: "LET"
  ## let_err_check '', 1
  ##   returns error 'Variable name missing'
  ##
  ##

  def test_let_err_check
    assert_output(/Variable name missing/){ let_err_check '', 1 }
  end

  ## UNIT TEST FOR let_syntax_err_check
  ## this method handles other cases in let_err_check
  ##
  ## EDGE CASES:
  ## RPN expression: "LET a"
  ## let_syntax_err_check 'a', 1
  ##   returns error 'value missing'
  ##
  ## RPN expression: "LET 5"
  ## let_syntax_err_check '5', 1
  ##   returns error 'invalid variable name'
  ##  

  def test_let_syntax_err_check_value_missing
    assert_output(/Value missing/){ let_syntax_err_check 'a'.split, 1}
  end

  def test_let_syntax_err_check_invalid_var_name
    assert_output(/Invalid variable name/){ let_syntax_err_check '5'.split, 1}
  end

  ## UNIT TEST FOR operator?
  ## checks if the given value is a valid operator
  ## Valid operators: +, -, *, /
  ## Invalid operators / EDGE CASES: none of the above
  ##
  ##

  def test_operator_true
    assert_equal (operator? '*'), true
  end

  def test_operator_false
    assert_equal (operator? '**'), false
  end

  ## UNIT TEST FOR not_operator?
  ## does the opposite of operator?
  ## 
  ## Valid Cases: none of the below
  ## Invalid Cases / EDGE CASES: +, -, *, /
  ##

  def test_not_operator_true
    assert_equal (not_operator? '**'), true
  end

  def test_not_operator_false
    assert_equal (not_operator? '*'), false
  end
end
