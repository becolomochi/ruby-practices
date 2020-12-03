#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'Date'

# ターミナルから値を得る
opt = OptionParser.new
params = {}
opt.on('-a') {|v| params[:a] = v }
opt.on('-l') {|v| params[:l] = v }
opt.on('-r') {|v| params[:r] = v }
# 値を取り出す
opt.parse!(ARGV)

# 確認
# puts 'ディレクトリ'
# p ARGV[0]
# puts 'オプション'
# p params

# ディレクトリを決める
directory = ARGV[0] || '.'
Dir.chdir(directory)

# ファイルの一覧を得る
file_list = if params[:a]
              Dir.glob("*", File::FNM_DOTMATCH)
            else
              Dir.glob("*")
            end.sort

# rオプションがあるなら逆順にする
file_list = file_list.reverse if params[:r]

# Fileクラスを定義
class File
  attr_reader :name, :type, :mode, :nlink, :user_name, :group_name, :size, :updated_time, :blocks

  def initialize(name, type, mode, nlink, user_name, group_name, size, updated_time, blocks)
    @name = name
    @type = type
    @mode = mode
    @nlink = nlink
    @user_name = user_name
    @group_name = group_name
    @size = size
    @updated_time = updated_time
    @blocks = blocks
  end

  # ftype からファイルタイプを変換
  def type_alphabet
    case type
    when 'file'
      '-'
    when 'directory'
      'd'
    when 'characterSpecial'
      'c'
    when 'blockSpecial'
      'b'
    when 'fifo'
      'p'
    when 'link'
      'l'
    when 'socket'
      's'
    when 'unknown'
      '?'
    end
  end

  # mode からパーミッションを変換
  def permission
    mode.to_s(8)[-3..-1].chars.map do |x|
      case x
      when '7'
        'rwx'
      when '6'
        'rw-'
      when '5'
        'r-x'
      when '4'
        'r--'
      when '2'
        '-w-'
      when '1'
        '--x'
      else
        '---'
      end
    end.join
  end

  def date
    if updated_time.year == Date.today
      updated_time.strftime("%b %d %Y")
    else
      updated_time.strftime("%b %d %H:%M")
    end
  end
end

# ファイルのデータを作成する
files = []
file_list.each do |f|
  fs = File::Stat.new(Dir.getwd + '/' + f)
  name = f
  type = fs.ftype
  mode = fs.mode
  nlink = fs.nlink
  user_name = Etc.getpwuid(fs.uid).name
  group_name = Etc.getgrgid(fs.gid).name
  size = fs.size
  updated_time = fs.mtime
  blocks = fs.blocks
  files << File.new(name, type, mode, nlink, user_name, group_name, size, updated_time, blocks)
end

# p files
if params[:l]
  total_blocks = 0
  files.each do |file|
    total_blocks += file.blocks
  end
  puts "total #{total_blocks}"
end

# ファイルを出力
files.each do |file|
  if params[:l]
    puts "#{file.type_alphabet}#{file.permission} #{file.nlink} #{file.user_name} #{file.group_name} #{file.size} #{file.date} #{file.name}"
  else
    # TODO: 3カラム表示
    puts "#{file.name}"
  end
end

# 出力
#   最大文字数からカラム幅を決める
  # col_size = 0
  # files.each do |n|
  #   if col_size < n.size
  #     col_size = n.size
  #   end
  # end
  #
  # col1 = if files.size == 3
  #          files.shift(1)
  #        else
  #          files.shift(files.size / 3 + 1)
  #        end
  # col2 = if files.size.even?
  #          files.shift(files.size / 2)
  #        else
  #          files.shift(files.size / 2 + 1)
  #        end
  # col3 = files
  # items = [col1, col2, col3]
  #
  # row = col1.size
  # (0..row).each do |j|
  #   col = ''
  #   items.each_with_index do |item, i|
  #     col += items[i][j]&.ljust(col_size + 1) || ''
  #   end
  #   puts col
  # end
