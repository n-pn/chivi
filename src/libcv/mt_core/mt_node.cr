require "../vp_dict/vp_term"
require "./mt_node/*"

class CV::MtNode
  property idx : Int32
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

  def update!(@val = @val, @tag = @tag, @dic = 1) : self
    self
  end

  def prepend!(other : self) : Nil
    @key = "#{other.key}#{@key}"
    @val = "#{other.val}#{@val}"
    @dic = other.dic if @dic < other.dic
  end

  def fuse_left!(left = "#{@prev.try(&.val)}", right = "", @dic = 6) : self
    return self unless prev = @prev

    @key = "#{prev.key}#{@key}"
    @val = "#{left}#{@val}#{right}"

    self.prev = prev.prev
    self.prev.try(&.succ = self)

    self
  end

  def fuse_right!(@val : String = "#{@val}#{@succ.try(&.val)}", @dic = 6) : self
    return self unless succ = @succ

    @key = "#{@key}#{succ.key}"

    self.succ = succ.succ
    self.succ.try(&.prev = self)

    self
  end

  def fuse_的!(succ : self, succ_succ : self, join = " ")
    @key = "#{@key}#{succ.key}#{succ_succ.key}"
    @val = "#{succ_succ.val}#{join}#{val}"
    @tag = succ_succ.tag
    @dic = succ_succ.dic if @dic < succ_succ.dic
    self.set_succ(succ_succ.succ)
  end

  def replace!(@key, @val, @tag, @dic, succ)
    self.set_succ(succ)
  end

  include MTL::ApplyCap
  include MTL::Serialize

  def clear!
    @key = ""
    @val = ""
    @tag = PosTag::None
    @dic = 0
  end
end
