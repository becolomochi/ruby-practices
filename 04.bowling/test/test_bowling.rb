# frozen_string_literal: true

require 'minitest/autorun'

class BowlingTest < Minitest::Test
  def test_bowling_example1
    input = '6390038273X9180X645'
    output = `./bowling.rb #{input}`
    assert_equal 139, output.to_i
  end

  def test_bowling_example2
    input = '6390038273X9180XXXX'
    output = `./bowling.rb #{input}`
    assert_equal 164, output.to_i
  end

  def test_bowling_example3
    input = '0X150000XXX518104'
    output = `./bowling.rb #{input}`
    assert_equal 107, output.to_i
  end

  def test_bowling_last_zero1
    input = '6390038273X9180X640'
    output = `./bowling.rb #{input}`
    assert_equal 134, output.to_i
  end

  def test_bowling_last_zero2
    input = '6390038273X9180XX00'
    output = `./bowling.rb #{input}`
    assert_equal 134, output.to_i
  end

  def test_bowling_last_zero3
    input = '6390038273X9180X0X0'
    output = `./bowling.rb #{input}`
    assert_equal 134, output.to_i
  end
end
