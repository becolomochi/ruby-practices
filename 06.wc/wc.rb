#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
# require 'etc'
# require 'date'

def main
  hash = option_parser
  if hash[:target]
    file = WcFile.new(hash[:target])
  else
    line = ''
    while string = STDIN.gets
      break if string.chomp == "exit"
      line += string
    end
    file = WcStdin.new(line)
  end
  rows = create_rows(file, hash)
  puts rows.map {|row| row.rjust(8)}.join
end

class WcStdin
  attr_reader :file_read, :name

  def initialize(line)
    @file_read = line
    @name = ''
  end
  
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

class WcFile
  attr_reader :file_read, :name

  def initialize(file)
    @file_read = File.open(file).read
    @name = file
  end
  
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

# ターミナルから値を得る
def option_parser
  hash = {}

  opt = OptionParser.new
  params = {}
  opt.on('-l') { |v| params[:l] = v }
  # 値を取り出す
  opt.parse!(ARGV)

  hash[:target] = ARGV[0]
  hash[:option] = params[:l]
  hash
end

def create_rows(file, hash)
  rows = []
  if hash[:option]
    rows << file.count_line.to_s
  else
    rows << file.count_line.to_s
    rows << file.count_word.to_s
    rows << file.count_byte.to_s
  end
  rows << " " + file.name
end

# ファイルを直接実行されたときだけ実行
if __FILE__ == $0
  main
end
