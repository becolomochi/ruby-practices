# frozen_string_literal: true

require 'minitest/autorun'
require './wc'

class WcTest < Minitest::Test
  def test_en_txt
    file = Wc.new(File.expand_path('../sample_en.txt', __dir__))
    assert_equal 2, file.count_line
    assert_equal 8, file.count_word
    assert_equal 34, file.count_byte
  end

  def test_ja_txt
    file = Wc.new(File.expand_path('../sample_ja.txt', __dir__))
    assert_equal 3, file.count_line
    assert_equal 8, file.count_word
    assert_equal 144, file.count_byte
  end
end
