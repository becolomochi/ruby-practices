#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

# ターミナルから値を得る
opt = OptionParser.new
params = {}
opt.on('-a') { |v| params[:a] = v }
opt.on('-l') { |v| params[:l] = v }
opt.on('-r') { |v| params[:r] = v }
# 値を取り出す
opt.parse!(ARGV)

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
  def type_short
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

  def type_and_permission
    self.type_short + self.permission
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

# lオプション指定時はファイルのブロック数の合計を表示
if params[:l]
  total_blocks = 0
  files.each do |file|
    total_blocks += file.blocks
  end
  puts "total #{total_blocks}"
end

unless params[:l]
  # ファイル名の最大文字数からカラム幅を決める
  col_size = 0
  files.each do |file|
    if col_size < file.name.size
      col_size = file.name.size
    end
  end
  # ファイル名だけの配列を返す
  array_file_name = []
  files.each do |file|
    array_file_name << file.name
  end
end

# ファイルを出力
if params[:l]
  files.each do |file|
    puts "#{file.type_and_permission} #{file.nlink} #{file.user_name} #{file.group_name} #{file.size} #{file.date} #{file.name}"
  end
else
  # 3カラム表示
  col1 = if array_file_name.size == 3
           array_file_name.shift(1)
         else
           array_file_name.shift(array_file_name.size / 3 + 1)
         end
  col2 = if array_file_name.size.even?
           array_file_name.shift(array_file_name.size / 2)
         else
           array_file_name.shift(array_file_name.size / 2 + 1)
         end
  col3 = array_file_name
  cols = [col1, col2, col3]
  p cols

  (0...col1.size).each do |j|
    col = ''
    (0...3).each do |i|
      col += cols[i][j]&.ljust(col_size + 1) || ''
    end
    puts col
  end
end
