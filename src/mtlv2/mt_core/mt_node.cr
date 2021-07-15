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
    @tag = term.ptag
    @dic = term.dtype
  end

  def initialize(char : Char)
    @key = @val = char.to_s
    @tag = char.alphanumeric? ? PosTag::String : PosTag::None
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

  def update!(@val = @val, @tag = @tag, @dic = 9) : Nil
  end

  def prepend!(other : self) : Nil
    @key = "#{other.key}#{@key}"
    @val = "#{other.val}#{@val}"
    @dic = other.dic if @dic < other.dic
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
