require "db"
require "./pos_tag"

class MT::MtTerm
  include DB::Serializable
  # include DB::Serializable::NonStrict

  getter key : String

  getter val : String
  getter alt : String?

  getter ptag : String
  getter wseg : Int32

  @[DB::Field(ignore: true)]
  getter pos : MtlPos = MtlPos::None
  @[DB::Field(ignore: true)]
  getter tag : MtlTag = MtlTag::LitBlank
  @[DB::Field(ignore: true)]
  getter seg : Int32 = 0

  def self.new(rs : ::DB::ResultSet)
    instance = allocate
    instance.initialize(__set_for_db_serializable: rs)
    GC.add_finalizer(instance) if instance.responds_to?(:finalize)
    instance.after_initialize
    instance
  end

  def after_initialize
    @seg = MtTerm.seg_weight(@key.size, @wseg)
    @tag, @pos = PosTag.init(@ptag, @key, @val, @alt)
  end

  SEG_VALUE = {
    0, 3, 6, 9,
    0, 14, 18, 26,
    0, 25, 31, 40,
    0, 40, 45, 55,
    0, 58, 66, 78,
  }

  def self.seg_weight(wlen : Int32, wseg : Int32 = 2) : Int32
    SEG_VALUE[(wlen &- 1) &* 4 &+ wseg]? || wlen &* (wseg &* 2 &+ 7) &* 2
  end
end
