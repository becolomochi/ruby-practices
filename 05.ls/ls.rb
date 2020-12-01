#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

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


# ftype からファイルタイプを変換
def convert_filetype(ftype)
  case ftype
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
def convert_permission(mode)
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

# lオプションのファイル一覧を取得
if params[:l]
  # フルパスの取得
  path = Dir.getwd

  file_detail_list = []
  file_list.each do |f|
    fs = File::Stat.new("#{path}/#{f}")

    file_detail = {
        permission: convert_filetype(fs.ftype) + convert_permission(fs.mode),
        nlink: fs.nlink,
        uid: Etc.getpwuid(fs.uid).name,
        gid: Etc.getgrgid(fs.gid).name,
        size: fs.size,
        month: fs.mtime.month,
        day: fs.mtime.day,
        time: fs.mtime.hour.to_s + ':' + fs.mtime.min.to_s,
        year: fs.mtime.year,
        name: f
    }

    file_detail_list << file_detail
  end
end

# 出力
if params[:l]
  puts "total "
  file_detail_list.each do |item|
    puts item.values.join(" ")
  end
else
  # 最大文字数からカラム幅を決める
  col_size = 0
  file_list.each do |n|
    if col_size < n.size
      col_size = n.size
    end
  end

  col1 = if file_list.size == 3
           file_list.shift(1)
         else
           file_list.shift(file_list.size / 3 + 1)
         end
  col2 = if file_list.size.even?
           file_list.shift(file_list.size / 2)
         else
           file_list.shift(file_list.size / 2 + 1)
         end
  col3 = file_list
  items = [col1, col2, col3]

  row = col1.size
  (0..row).each do |j|
    col = ''
    items.each_with_index do |item, i|
      col += items[i][j]&.ljust(col_size + 1) || ''
    end
    puts col
  end
end
