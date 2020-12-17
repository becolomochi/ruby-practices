# frozen_string_literal: true

require 'minitest/autorun'
require './ls'

class LsTest < Minitest::Test
  def test_file_ls
    test_file = FileData.new(File.expand_path('../ls.rb', __dir__))
    assert_equal '-', test_file.type_short
    assert_equal 'rwxr-xr-x', test_file.permission
    assert_equal 1, test_file.nlink
    assert_equal 'beco', test_file.user_name
    assert_equal 'staff', test_file.group_name
  end

  def test_file_readme
    test_file = FileData.new(File.expand_path('../../README.md', __dir__))
    assert_equal '-', test_file.type_short
    assert_equal 'rw-r--r--', test_file.permission
  end

  def test_file_directory
    test_file = FileData.new(File.expand_path('../', __dir__))
    assert_equal 'd', test_file.type_short
    assert_equal 'rwxr-xr-x', test_file.permission
  end
end
