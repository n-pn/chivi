require "../vp_dict/vp_term"
require "./mt_node/*"

class CV::MtNode
  property idx : Int32 = -1
  property key : String = ""
  property val : String = ""
  property tag : PosTag = PosTag::None
  property dic : Int32 = 0

  property! prev : MtNode
  property! succ : MtNode
  property! body : MtNode

  forward_missing_to @tag

  def initialize(term : VpTerm, @idx = -1)
    @key = term.key
    @val = term.val.first
    @tag = term.ptag
    @dic = term.dtype
  end

  def initialize(char : Char, @idx = -1)
    @key = @val = char.to_s
    @tag = char.alphanumeric? ? PosTag::String : PosTag::None
  end

  def initialize(@key, @val = @key, @tag = PosTag::None, @dic = 0, @idx = -1)
  end

  def prev?
    @prev.try { |x| yield x }
  end

  def succ?
    @succ.try { |x| yield x }
  end

  def set_prev(node : self) : self # return node
    if prev = @prev
      prev.succ = node
      node.prev = prev
    end

    node.succ = self
    @prev = node
  end

  def set_prev(@prev : Nil) : self
    self
  end

  def set_succ(node : self) : self # return node
    if succ = @succ
      succ.prev = node
      node.succ = succ
    end

    node.prev = self
    @succ = node
  end

  def set_succ(@succ : Nil) : self
    self
  end

  include MTL::ApplyCap
  include MTL::Serialize
  include MTL::Transform
end
