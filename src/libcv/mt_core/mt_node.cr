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

  def initialize(term : VpTerm, @dic : Int32 = 0, @idx = -1)
    @key = term.key
    @val = term.val.first
    @tag = term.ptag
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

  def fix_prev!(@prev : self) : self
    prev.succ = self
    self
  end

  def fix_prev!(@prev : Nil)
    self
  end

  def fix_succ!(@succ : self) : self
    succ.prev = self
  end

  def fix_succ!(@succ : Nil) : self
    self
  end

  def fold_left!(left : Nil)
    self
  end

  def fold_left!(left : self, tag = @tag)
    left.tag = tag
    left.fold!(self)
  end

  def fold!(succ : self, @val = "#{@val} #{succ.val}", @dic = 6) : self
    @key = "#{@key}#{succ.key}"
    fix_succ!(succ.succ?)
  end

  def fold_many!(*succ : self)
    key_io = String::Builder.new(@key)
    succ.each { |x| key_io << x.key }
    @key = key_io.to_s
    fix_succ!(succ[-1].succ?)
  end

  def fold!(val : String = "#{@val} #{succ.val}", dic = 6) : self
    fold!(succ, val, dic)
  end

  def heal!(@val : String = self.val, @tag : PosTag = self.tag)
    self
  end

  include MTL::ApplyCap
  include MTL::Serialize
  include MTL::Transform
end
