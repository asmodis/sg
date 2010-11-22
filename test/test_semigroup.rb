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

class TestSemigroupSpecialElements < MiniTest::Unit::TestCase
  include Sg
  
  def setup
    @s = Semigroup.new  %w(a b c b c a c a b), %w(a b c)
    @t = Semigroup.new  %w(b b b b), %w(a b)
  end

  def test_identity
    assert_equal 'a', @s.identity
    assert_nil @t.identity
  end

  def test_zero
    assert_equal 'b', @t.zero
    assert_nil @s.zero
  end
end

class TestSemigroupAdjoinOperations < MiniTest::Unit::TestCase
  include Sg

  def setup
    @s = Semigroup.new  %w(b b b b), %w(a b)
    @t = Semigroup.new  %w(a b b a), %w(a b)
  end

  def test_adjoin_identity
    @s.adjoin! :identity, 'c'

    assert_equal 3, @s.order
    assert_equal %w(a b c), @s.elements
    assert_equal({'a' => 0, 'b' => 1, 'c' => 2}, @s.internal)
    assert_equal [1,1,0,1,1,1,0,1,2], @s.table

    assert_equal 'c', @s.identity
  end

  def test_adjoin_zero
    @t.adjoin! :zero, 'c'

    assert_equal 3, @t.order
    assert_equal %w(a b c), @t.elements
    assert_equal({'a' => 0, 'b' => 1, 'c' => 2}, @t.internal)
    assert_equal [0,1,2,1,0,2,2,2,2], @t.table

    assert_equal 'c', @t.zero
  end

    def test_adjoin_identity_not_needed
    @t.adjoin! :identity, 'c'

    assert_equal 2, @t.order
    assert_equal %w(a b), @t.elements
    assert_equal({'a' => 0, 'b' => 1}, @t.internal)
    assert_equal [0,1,1,0], @t.table

    assert_equal 'a', @t.identity
  end

  def test_adjoin_zero_not_needed
    @s.adjoin! :zero, 'c'

    assert_equal 2, @s.order
    assert_equal %w(a b), @s.elements
    assert_equal({'a' => 0, 'b' => 1}, @s.internal)
    assert_equal [1,1,1,1], @s.table

    assert_equal 'b', @s.zero
  end

  def test_adjoin_identity_forced
    @t.adjoin! :identity, 'c', true

    assert_equal 3, @t.order
    assert_equal %w(a b c), @t.elements
    assert_equal({'a' => 0, 'b' => 1, 'c' => 2}, @t.internal)
    assert_equal [0,1,0,1,0,1,0,1,2], @t.table

    assert_equal 'c', @t.identity
  end

  def test_adjoin_zero_forced
    @s.adjoin! :zero, 'c', true

    assert_equal 3, @s.order
    assert_equal %w(a b c), @s.elements
    assert_equal({'a' => 0, 'b' => 1, 'c' => 2}, @s.internal)
    assert_equal [1,1,2,1,1,2,2,2,2], @s.table

    assert_equal 'c', @s.zero
  end
end

