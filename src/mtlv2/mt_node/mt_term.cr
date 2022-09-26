require "../pos_tag"

class MTL::MtTerm
  property mtl : String
  property alt : String? = nil

  property tag : PosTag

  property idx : Int32 = 0
  property dic : Int32 = 0

  def initialize(@mtl, @tag, @_idx, @dic = 0)
  end
end
