class CV::CvTerm
  include DB::Serializable

  property id : Int32
  property dict_id : Int32

  property key : String
  property key_raw : String?

  property val : String
  property alt_val : String?

  property ptag : String = ""
  property epos : Int64 = 0
  property etag : Int32 = 0

  property seg_r : Int32 = 2
  property seg_w : Int32 = 0

  property uname : String = ""
  property mtime : Int64 = 0_i64

  property _prev : Int32?
  property _flag : Int32 = 0
  property _lock : Int32 = 0

  #####

  def self.seg_weight(size : Int32, seg_r : Int32 = 0) : Int32
    SEG_WEIGHT[(size &- 1) &* 4 &+ seg_r]? || size &* (seg_r &* 2 &+ 7) &* 2
  end

  SEG_WEIGHT = {
    0, 3, 6, 9,
    0, 14, 18, 26,
    0, 25, 31, 40,
    0, 40, 45, 55,
    0, 58, 66, 78,
  }
end
