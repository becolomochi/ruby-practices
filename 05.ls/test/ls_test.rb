# frozen_string_literal: true

require 'minitest/autorun'
require './ls'

# テスト動きません……
class LsTest < Minitest::Test
  def test_type
    assert_equal '-', type_short('file')
    assert_equal 'd', type_short('directory')
  end

  def test_permission
    assert_equal 'rwxr--r--', permission(33_252)
    assert_equal 'rwxr-xr-x', permission(16_877)
  end
end
