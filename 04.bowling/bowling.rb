#!/usr/bin/env ruby

score = ARGV[0]
scores = score.chars
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
  else
    shots << s.to_i
  end
end

# フレームごとに分ける
frames = []
frame = []
shots.each do |s|
  frame << s
  if frames.size < 9
    if frame[0] == 10 || frame[1]
      frames << frame
      frame = []
    end
  elsif frames.size == 9 # 10フレーム目
    frames << frame if shots.last
  end
end

# 得点を計算
point = 0
frames.each_with_index do |f, i|
  point += f.sum

  # 加算ポイント
  if f.size == 1 # ストライク
    next_1st_shot = frames[i + 1][0]
    # 次フレームがストライクで2投目がない場合、さらに次のフレームの1投目を呼び出す
    next_2nd_shot = frames[i + 1][1] || frames[i + 2][0]
    point += next_1st_shot + next_2nd_shot
  elsif f.sum == 10 # スペア
    # 次の1投の点数
    point += frames[i + 1][0]
  end
end
p point
