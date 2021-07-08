require "../../cutil/text_utils"
require "../vp_dict/vp_term"

class CV::MtNode
  property key : String
  property val : String = ""
  property tag : PosTag = PosTag::None
  property dic : Int32 = 0

  property prev : self | Nil = nil
  property succ : self | Nil = nil

  forward_missing_to @tag

  def prev!
    prev.not_nil!
  end

  def succ!
    succ.not_nil!
  end

  def initialize(term : VpTerm)
    @key = term.key
    @val = term.val.first
    @tag = term.tag
    @dic = term.dtype
  end

  def initialize(@key, @val = @key, @tag = PosTag::None, @dic = 0)
  end

  def set_prev(node : self) : self # return node
    if prev = @prev
      prev.succ = node
      node.prev = prev
    end

    node.succ = self
    @prev = node
  end

  def set_prev(@prev : Nil)
  end

  def set_succ(node : self) : self # return node
    if succ = @succ
      succ.prev = node
      node.succ = succ
    end

    node.prev = self
    @succ = node
  end

  def set_succ(@succ : Nil)
  end

  def update!(@val : String, @tag = @tag, @dic = 9) : Nil
  end

  def merge_left!(val_left = @prev.try(&.val) || "", val_right = "")
    return unless left = @prev
    self.set_prev(left.prev)

    @key = "#{left.key}#{@key}"
    @val = "#{val_left}#{@val}#{val_right}"
  end

  def capitalize!(cap_mode : Int32 = 1) : Nil
    @val = cap_mode > 1 ? TextUtils.titleize(@val) : TextUtils.capitalize(@val)
  end

  def similar?(other : self)
    return false if @tag == PosTag::None
    @tag == other.tag && @tag.puncts? || @tag.strings?
  end

  def absorb_similar!(other : self) : Nil
    @key = "#{other.key}#{@key}"
    @val = "#{other.val}#{@val}"
  end

  def merge!(key : String, val : String, cat : Int32 = 0, dic = @dic)
    @key = "#{@key}#{key}"
    @val = "#{@val} #{val}"
    @cat |= cat
    @dic = dic
  end

  def clear!
    @key = ""
    @val = ""
    @tag = PosTag::None
    @dic = 0
  end

  def to_str(io : IO)
    io << @key << 'ǀ' << @val << 'ǀ' << @tag.to_str << 'ǀ' << @dic
  end

  def inspect(io : IO)
    io << (val == " " ? val : "[#{@key}/#{@val}/#{@tag.to_str}/#{@dic}]")
  end
end
