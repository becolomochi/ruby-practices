#!/usr/bin/env ruby
# frozen_string_literal: true

# スコアを取得する
def create_score(score_text)
  score_text.chars.map do |score|
    score == 'X' ? 10 : score.to_i
  end
end
scores = create_score(ARGV[0])

# フレームごとに分ける
def separate_frame(shots)
  frames = []
  frame = []
  shots.each do |shot|
    if frames[9] # 10フレーム目の判定
      frames[9] << shot
    else
      frame << shot
      # スペアまたは2投目であれば新しいフレームを用意
      if frame[0] == 10 || frame[1]
        frames << frame
        frame = []
      end
    end
  end
  frames
end
game = separate_frame(scores)

# 得点を計算する
def count_point(frames)
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
  point
end

puts count_point(game)
