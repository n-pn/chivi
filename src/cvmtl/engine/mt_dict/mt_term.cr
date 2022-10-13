require "../pos_tag/*"

require "sqlite3"

class MT::MtTerm
  include DB::Serializable
  include DB::Serializable::NonStrict

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
  getter seg : Int32 = 1

  def self.new(rs : ::DB::ResultSet)
    instance = allocate
    instance.initialize(__set_for_db_serializable: rs)
    GC.add_finalizer(instance) if instance.responds_to?(:finalize)
    instance.after_initialize
    instance
  end

  def after_initialize
    @seg = MtTerm.seg_weight(@key.size, @prio)
    @tag, @pos = PosTag.init(@ptag, @key, @val, @alt_val)
  end

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
