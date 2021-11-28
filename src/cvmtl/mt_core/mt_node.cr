require "../vp_dict/vp_term"
require "./mt_node/*"
require "./mt_util"

class CV::MtNode
  property idx : Int32 = -1
  property key : String = ""
  property val : String = ""
  property tag : PosTag = PosTag::None
  property dic : Int32 = 0

  property! prev : MtNode
  property! succ : MtNode

  property! body : MtNode
  property! root : MtNode

  forward_missing_to @tag

  def initialize(term : VpTerm, @dic : Int32 = 0, @idx = -1)
    @key = term.key
    @val = term.val.first
    @tag = term.ptag
  end

  def initialize(char : Char, @idx = -1)
    @key = @val = char.to_s
    @tag =
      case char
      when ' ' then PosTag::Punct
      when '_' then PosTag::String
      else
        char.alphanumeric? ? PosTag::String : PosTag::None
      end
  end

  def initialize(@key, @val = @key, @tag = PosTag::None, @dic = 0, @idx = -1)
  end

  def blank?
    @key.empty? || @val == " "
  end

  def prev?
    @prev.try { |x| yield x }
  end

  def succ?
    @succ.try { |x| yield x }
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

  def fix_root!(@root : Nil) : self
    self
  end

  def fix_root!(@root : self) : self
    self
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

  def to_int?
    case @tag
    when .ndigit? then @val.to_i64?
    when .nhanzi? then MtUtil.to_integer(@key)
    else               nil
    end
  rescue err
    File.open("tmp/nhanzi-error.txt", "a", &.puts(@key))
    nil
  end

  include MTL::Serialize
  include MTL::ApplyCap
  include MTL::PadSpace
end
