require "sqlite3"

class MT::MtTerm
  include DB::Serializable

  getter key : String

  getter val : String
  getter alt_val : String?

  getter epos : UInt64 = 0
  getter etag : UInt32 = 0

  getter seg_w : Int32 = 0
end
