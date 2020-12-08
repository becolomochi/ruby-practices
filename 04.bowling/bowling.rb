#!/usr/bin/env ruby
# frozen_string_literal: true

score_text = ARGV[0]
scores = score_text.chars
shots = scores.map do |score|
  score == 'X' ? 10 : score.to_i
end

# フレームごとに分ける
frames = []
frame = []
shots.each do |shot|
  if frames[9] # 10フレーム目の判定
    if frames[9][1] # 2投目が存在する場合3投目を入れる
      frames[9][2] = shot
    elsif frames[9][0] # 1投目が存在する場合2投目を入れる
      frames[9][1] = shot
    else
      frames[9][0] = shot
    end
  else
    frame << shot
    # スペアまたは2投目であれば新しいフレームを用意
    if frame[0] == 10 || frame[1]
      frames << frame
      frame = []
    end
  end
end

# 得点を計算
point = 0
frames.each_with_index do |frame_score, i|
  point += frame_score.sum

  # 加算ポイントは9フレーム目まで
  if i < 9
    if frame_score.size == 1 # ストライク
      next_1st_shot = frames[i + 1][0]
      # 次フレームがストライクで2投目がない場合、さらに次のフレームの1投目を呼び出す
      next_2nd_shot = frames[i + 1][1] || frames[i + 2][0]
      point += next_1st_shot + next_2nd_shot
    elsif frame_score.sum == 10 # スペア
      # 次の1投の点数
      point += frames[i + 1][0]
    end
  end
end

puts point
