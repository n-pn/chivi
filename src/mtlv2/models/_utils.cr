module MT::Utils
  extend self

  SEG_WEIGHT = {
    0, 3, 6, 9,
    0, 14, 18, 26,
    0, 25, 31, 40,
    0, 40, 45, 55,
    0, 58, 66, 78,
  }

  def self.seg_weight(size : Int32, seg_r : Int32 = 0) : Int32
    SEG_WEIGHT[(size &- 1) &* 4 &+ seg_r]? || size &* (seg_r &* 2 &+ 7) &* 2
  end
end
