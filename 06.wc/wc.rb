#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  hash = option_parser
  if hash[:targets].size.positive?
    output_wc_file(hash)
  else
    output_wc_stdin(hash)
  end
end

# ファイルと標準入力を受け付けるクラス
class Wc
  attr_reader :target, :name

  def initialize(target, name)
    @target = target
    @name = name
  end

  def count_line
    target.count("\n")
  end

  def count_word
    target.split(' ').length
  end

  def count_byte
    target.bytesize
  end
end

# ファイルを受け付けたときの出力
def output_wc_file(hash)
  files = hash[:targets].map { |target| Wc.new(File.open(target).read, target) }
  files.each do |file|
    rows = create_rows(file, hash)
    puts rows.join
  end
  puts total_count(files, hash) if hash[:targets].size > 1
end

# 標準入力を受け付けたときの出力
def output_wc_stdin(hash)
  file = Wc.new($stdin.gets(''), '')
  rows = create_rows(file, hash)
  puts rows.join
end

# ターミナルからの値を受け付ける
def option_parser
  hash = {}

  opt = OptionParser.new
  params = {}
  opt.on('-l') { |v| params[:l] = v }
  opt.parse!(ARGV)

  hash[:targets] = ARGV
  hash[:option] = params[:l]
  hash
end

# 表示の整形
def to_s_right(number)
  number.to_s.rjust(8)
end

# 出力
def create_rows(file, hash)
  rows = []
  rows << to_s_right(file.count_line)
  unless hash[:option]
    rows << to_s_right(file.count_word)
    rows << to_s_right(file.count_byte)
  end
  rows << " #{file.name}"
end

# ファイルが複数ある場合の合計数
def total_count(files, hash)
  rows = []
  rows << to_s_right(files.map(&:count_line).sum)
  unless hash[:option]
    rows << to_s_right(files.map(&:count_word).sum)
    rows << to_s_right(files.map(&:count_byte).sum)
  end
  rows << ' total'
  rows.join
end

# ファイルを直接実行されたときだけ実行
main if __FILE__ == $PROGRAM_NAME
