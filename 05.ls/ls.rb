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
    }[type]
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
    type_short + permission
  end

  def date
    if updated_time.year == Date.today
      updated_time.strftime('%b %d %Y')
    else
      updated_time.strftime('%b %d %H:%M')
    end
  end
end

def total_blocks(files)
  files.map(&:blocks).sum
end

def file_names(files)
  files.map(&:name)
end

def column_width(file_names)
  file_names.map(&:length).max + 1
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


# ファイルを出力
if params[:l]
  puts "total #{total_blocks(files)}"
  files.each do |file|
    puts "#{file.type_and_permission} #{file.nlink} #{file.user_name} #{file.group_name} #{file.size} #{file.date} #{file.name}"
  end
else
  # 3カラム表示
  file_names(files).each_slice(3) do |file_name|
    column = file_name.map do |name|
      name&.ljust(column_width(file_names(files)))
    end
    puts column.join
  end
end
