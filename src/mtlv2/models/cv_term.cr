require "sqlite3"

class MT::CvTerm
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
end
