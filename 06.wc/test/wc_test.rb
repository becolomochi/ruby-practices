# frozen_string_literal: true

require 'minitest/autorun'
require './wc'

class WcTest < Minitest::Test
  def test_en_txt
    file = Wc.new(File.open(File.expand_path('../sample/sample_en.txt', __dir__)).read, 'sample/sample_en.txt')
    assert_equal 2, file.count_line
    assert_equal 8, file.count_word
    assert_equal 34, file.count_byte
  end

  def test_ja_txt
    file = Wc.new(File.open(File.expand_path('../sample/sample_ja.txt', __dir__)).read, 'sample/sample_ja.txt')
    assert_equal 3, file.count_line
    assert_equal 8, file.count_word
    assert_equal 144, file.count_byte
  end

  def test_stdin_sample_directory
    output = `ls -l #{File.expand_path('../sample/', __dir__)}`

    file = Wc.new(output, '')
    assert_equal 3, file.count_line
    assert_equal 20, file.count_word
    assert_equal 125, file.count_byte
  end
end
