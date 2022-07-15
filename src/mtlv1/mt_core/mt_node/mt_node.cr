require "../../vp_dict/vp_term"

abstract class CV::MtNode
  forward_missing_to @tag

  property dic : Int32 = 0
  property tag : PosTag = PosTag::None

  property! prev : MtNode
  property! succ : MtNode

  def initialize(@tag = PosTag::None, @dic = 0, @idx = -1)
  end

  def prev?
    @prev.try { |x| yield x }
  end

  def succ?
    @succ.try { |x| yield x }
  end

  def fix_prev!(@prev : Nil) : Nil
  end

  def fix_prev!(@prev : self) : Nil
    prev.succ = self
  end

  def fix_succ!(@succ : Nil) : Nil
  end

  def fix_succ!(@succ : self) : Nil
    succ.prev = self
  end

  def maybe_verb? : Bool
    succ = self
    while succ
      # puts [succ, "maybe_verb", succ.verbal?]
      case succ
      when .verbal?, .vmodals? then return true
      when .adverbial?, .comma?, pro_ints?, .conjunct?, .ntime?
        succ = succ.succ?
      else return false
      end
    end

    false
  end

  def maybe_adjt? : Bool
    return !@succ.try(&.maybe_verb?) if @tag.ajad?
    @tag.adjective? || @tag.adverbial? && @succ.try(&.maybe_adjt?) || false
  end

  abstract def starts_with?(key : String | Char)
  abstract def ends_with?(key : String | Char)
  abstract def find_key?(key : String | Char)
  abstract def apply_cap!(cap : Bool)

  abstract def to_txt(io : IO)
  abstract def to_mtl(io : IO)
  abstract def inspect(io : IO)
end
