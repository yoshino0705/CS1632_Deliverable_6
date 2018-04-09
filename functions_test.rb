# require 'simplecov'
# SimpleCov.start
require 'minitest/autorun'
require_relative 'functions'
require_relative 'utilities'

class RPN_test < Minitest::Test
  def setup
    @rpn_repl = RPN.new 'REPL'
    @rpn_file = RPN.new 'FILE'
  end

  ## UNIT TEST FOR format_result
  
  def test_format_result_int
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []
    @rpn_repl.format_result 100.0
    assert_equal @rpn_repl.result, 100
  end

  def test_format_result_float
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []
    @rpn_repl.format_result 100.99
    assert_equal @rpn_repl.result, 100.99
  end

  ## UNIT TEST FOR let

  def test_let_valid_syntax
    @rpn_repl.error['bool'] = false
    syntax = 'p 90'.split
    @rpn_repl.let syntax
    assert_equal @rpn_repl.variables['P'], 90.0
    assert_equal @rpn_repl.error['bool'], false
  end

  def test_let_invalid_syntax
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []
    syntax = 'p chan'.split
    @rpn_repl.let syntax
    assert_equal @rpn_repl.variables['P'], nil.to_f
    assert_equal @rpn_repl.error['bool'], true
  end

  ## UNIT TEST FOR execute_keywords

  def test_execute_keywords_let_valid_var_name
    @rpn_repl.error['bool'] = false
    @rpn_repl.operands = []
    syntax = 'let p 9 10 *'.split
    @rpn_repl.execute_keywords syntax.drop(1), syntax[0]
    assert_equal @rpn_repl.variables['P'], 90.0
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

  ## UNIT TEST FOR update_result

end