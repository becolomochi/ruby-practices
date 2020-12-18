# frozen_string_literal: true

require 'minitest/autorun'
require './wc'

class WcTest < Minitest::Test
  def test_en_txt
    file = WcFile.new(File.expand_path('../sample_en.txt', __dir__))
    assert_equal 2, file.count_line
    assert_equal 8, file.count_word
    assert_equal 34, file.count_byte
  end

  def test_ja_txt
    file = WcFile.new(File.expand_path('../sample_ja.txt', __dir__))
    assert_equal 3, file.count_line
    assert_equal 8, file.count_word
    assert_equal 144, file.count_byte
  end

  def text_stdin_current_directory
    file = WcStdin.new(File.expand_path('.', __dir__))
    assert_equal 5, file.count_line
    assert_equal 5, file.count_word
    assert_equal 48, file.count_byte
  end

  def text_stdin_parent_directory
    file = WcStdin.new(File.expand_path('../', __dir__))
    assert_equal 10, file.count_line
    assert_equal 10, file.count_word
    assert_equal 109, file.count_byte
  end

  def text_stdin_grandparents_directory
    file = WcStdin.new(File.expand_path('../../', __dir__))
    assert_equal 5, file.count_line
    assert_equal 5, file.count_word
    assert_equal 74, file.count_byte
  end
end
