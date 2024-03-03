require "../pos_tag"
require "../../../_util/text_util"

abstract class M1::MtNode
  forward_missing_to @tag

  property key : String = ""
  property val : String = ""

  property tag : PosTag = PosTag::None

  property dic : Int32 = 0
  property idx : Int32 = 0

  property! prev : MtNode
  property! succ : MtNode

  def prev?(&)
    @prev.try { |x| yield x }
  end

  def succ?(&)
    @succ.try { |x| yield x }
  end

  def fix_prev!(prev : Nil) : Nil
    @prev = nil
  end

  def fix_prev!(@prev : MtNode) : Nil
    prev.succ = self
  end

  def fix_succ!(succ : Nil) : Nil
    @succ = nil
  end

  def fix_succ!(@succ : MtNode) : Nil
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

  def aspect?
    @tag.ule? || @tag.uguo? || @tag.uzhe?
  end

  def vcompl?
    @tag.adj_hao? || @tag.vdir? || MtDict.get(:v_compl).has_key?(@key)
  end

  def maybe_adjt? : Bool
    return !@succ.try(&.maybe_verb?) if @tag.ajad?
    @tag.adjective? || @tag.adverbial? && @succ.try(&.maybe_adjt?) || false
  end

  def set!(@val : String) : self
    self
  end

  def set!(@tag : PosTag) : self
    self
  end

  def set!(@val : String, @tag : PosTag) : self
    self
  end

  abstract def starts_with?(key : String | Char)
  abstract def ends_with?(key : String | Char)
  abstract def find_by_key(key : String | Char)
  abstract def apply_cap!(cap : Bool)

  abstract def to_txt(io : IO)
  abstract def to_mtl(io : IO)
  abstract def inspect(io : IO)

  def space_before?(prev : Nil) : Bool
    false
  end

  def space_before?(prev : MtNode)
    return !prev.popens? unless prev.is_a?(MtDefn)
    return space_before?(prev.prev?) if prev.val.empty?
    !(prev.val.blank? || prev.popens?)
  end

  def key_is?(key : String)
    false
  end

  def key_in?(*keys : String)
    false
  end
end
