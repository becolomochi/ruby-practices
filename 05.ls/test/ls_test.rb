# frozen_string_literal: true
require 'minitest/autorun'
require './ls'

class LsTest < Minitest::Test
  def test_type
    assert_equal '-', convert_filetype('file')
    assert_equal 'd', convert_filetype('directory')
  end

  def test_permission
    assert_equal 'rwxr--r--', permission(33252)
    assert_equal 'rwxr-xr-x', permission(16877)
  end
end
