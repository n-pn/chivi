require "./_utils"
require "../pos_tag/map_tag"

require "sqlite3"

class MT::MtTerm
  include DB::Serializable

  getter key : String

  getter val : String
  getter alt_val : String?

  getter ptag : String
  getter prio : Int32

  @[DB::Field(ignore: true)]
  getter pos : MtlPos = MtlPos::None
  @[DB::Field(ignore: true)]
  getter tag : MtlTag = MtlTag::LitBlank
  @[DB::Field(ignore: true)]
  getter seg : Int32 = 0

  def after_initialize
    @seg = Utils.seg_weight(prio, key.size)
    @tag, @pos = MapTag.init(@ptag, key, val, al_val)
  end
end
