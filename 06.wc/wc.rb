#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  hash = option_parser
  if hash[:targets].size.positive?
    files = hash[:targets].map { |target| WcFile.new(target) }
    files.each do |file|
      rows = create_rows(file, hash)
      puts rows.map { |row| row }.join
    end
  else
    line = ''
    while string = $stdin.gets
      break if string.chomp == 'exit'

      line += string
    end
    file = WcStdin.new(line)
    rows = create_rows(file, hash)
    puts rows.map { |row| row }.join
  end

  puts total_count(files, hash) if hash[:targets].size > 1
end

# 行数・単語数・バイト数の計算
module Count
  def count_line
    file_read.count("\n")
  end

  def count_word
    file_read.split(' ').length
  end

  def count_byte
    file_read.bytesize
  end
end

# 標準入力を受け付けるクラス
class WcStdin
  attr_reader :file_read, :name

  def initialize(line)
    @file_read = line
    @name = ''
  end

  include Count
end

# ファイルを受け付けるクラス
class WcFile
  attr_reader :file_read, :name

  def initialize(file)
    @file_read = File.open(file).read
    @name = file
  end

  include Count
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
  rows.map { |row| row }.join
end

# ファイルを直接実行されたときだけ実行
main if __FILE__ == $PROGRAM_NAME
