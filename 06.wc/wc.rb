#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  hash = option_parser
  if hash[:targets].size > 0
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
    puts rows.map { |row| row.rjust(8) }.join
  end

  if hash[:targets].size > 1
    rows = []
    rows << files.map(&:count_line).sum.to_s.rjust(8)
    unless hash[:option]
      rows << files.map(&:count_word).sum.to_s.rjust(8)
      rows << files.map(&:count_byte).sum.to_s.rjust(8)
    end
    rows << ' total'
    puts rows.map { |row| row }.join
  end
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

def create_rows(file, hash)
  rows = []
  rows << file.count_line.to_s.rjust(8)
  unless hash[:option]
    rows << file.count_word.to_s.rjust(8)
    rows << file.count_byte.to_s.rjust(8)
  end
  rows << " #{file.name}"
end

# ファイルを直接実行されたときだけ実行
main if __FILE__ == $PROGRAM_NAME
