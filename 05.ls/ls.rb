#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

class FileData
  attr_reader :file, :name, :type, :mode, :nlink, :user_name, :group_name, :size, :updated_time, :blocks

  def initialize(file)
    fs = File::Stat.new(file)
    @name = file
    @type = fs.ftype
    @mode = fs.mode
    @nlink = fs.nlink
    @user_name = Etc.getpwuid(fs.uid).name
    @group_name = Etc.getgrgid(fs.gid).name
    @size = fs.size
    @updated_time = fs.mtime
    @blocks = fs.blocks
  end

  # ftype からファイルタイプを変換
  def type_short
    {
      'file' => '-',
      'directory' => 'd',
      'characterSpecial' => 'c',
      'blockSpecial' => 'b',
      'fifo' => 'p',
      'link' => 'l',
      'socket' => 's',
      'unknown' => '?'
    }[@type]
  end

  # mode からパーミッションを変換
  def permission
    @mode.to_s(8)[-3..-1].chars.map do |x|
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
    type_short + permission
  end

  def date
    if @updated_time.year == Date.today
      @updated_time.strftime('%b %d %Y')
    else
      @updated_time.strftime('%b %d %H:%M')
    end
  end
end

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
              Dir.glob('*', File::FNM_DOTMATCH)
            else
              Dir.glob('*')
            end.sort

# rオプションがあるなら逆順にする
file_list = file_list.reverse if params[:r]

# ファイルのデータを作成する
files = file_list.map do |file|
  FileData.new(file)
end

# lオプション指定時はファイルのブロック数の合計を表示
if params[:l]
  total_blocks = files.inject(0) { |sum, file| sum + file.blocks }
  puts "total #{total_blocks}"
end

unless params[:l]
  # ファイル名だけの配列を返す
  array_file_name = files.map(&:name)
  # ファイル名の最大文字数
  max_file_name_length = array_file_name.map(&:length).max
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

  (0...col1.size).each do |j|
    col = ''
    (0...3).each do |i|
      col += cols[i][j]&.ljust(max_file_name_length + 1) || ''
    end
    puts col
  end
end
