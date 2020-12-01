require 'minitest/autorun'
require './ls'

class LsTest < Minitest::Test
  def test_convert_filetype
    assert_equal '-', convert_filetype('file')
    assert_equal 'd', convert_filetype('directory')
    # assert_equal '-', convert_filetype('unknown')
  end

  def test_convert_permission
    # assert_equal '-rwxr--r--', convert_permission(33252)
    # assert_equal 'drwxr-xr-x', convert_permission(16877)
    assert_equal "rwxr--r--", convert_permission(33252)
    assert_equal "rwxr-xr-x", convert_permission(16877)
    # assert_equal "rwxr--rx-", convert_permission(33252)
  end

  # def test_convert_user
  #   assert_equal "beco", convert_user(501)
  # end
end
