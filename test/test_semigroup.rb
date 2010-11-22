require File.absolute_path(File.join(File.dirname(__FILE__), "setup_testenv"))

require "semigroup"

class TestSemigroupCreation < MiniTest::Unit::TestCase
  include Sg
  
  def test_instancevars_are_correctly_initialized
    s = Semigroup.new %w(a b c b c a c a b), %w(a b c)

    assert_equal 3, s.order
    assert_equal %w(a b c), s.elements
    assert_equal({'a' => 0, 'b' => 1, 'c' => 2}, s.internal)
    assert_equal [0,1,2,1,2,0,2,0,1], s.table
  end
  
  def test_check_for_associativity
    exception = assert_raises ArgumentError do
      Semigroup.new %w(a b c b c a c a c), %w(a b c)
    end

    assert_match(/not associative/, exception.message)
  end

  def test_check_elements_matches_table_size
    exception = assert_raises ArgumentError do
      Semigroup.new %w(a a a a a a a a a), %w(a b)
    end

    assert_match(/wrong number/, exception.message)
  end

  def test_check_elements_of_table_are_really_elements
    exception = assert_raises ArgumentError do
      Semigroup.new %w(a a a a a a a a d), %w(a b c)
    end

    assert_match(/unknown element/, exception.message)
  end
end

class TestSemigroupMultiplication < MiniTest::Unit::TestCase
  include Sg
  
  def setup
    @s = Semigroup.new %w(a b c b c a c a b), %w(a b c)
  end

  def test_multiplication_of_two_elements
    assert_equal 'a', @s['a','a']
    assert_equal 'a', @s['b','c']
    assert_equal 'b', @s['c','c']
  end

  def test_multiplication_of_more_than_two_elements
    assert_equal 'a', @s['a','a','a','a']
    assert_equal 'c', @s['b','c','b','c','c']
  end

  def test_validation_of_arguments
    exception = assert_raises(ArgumentError) { @s['x','a'] }

    assert_match(/unknown element/, exception.message)
  end
end

