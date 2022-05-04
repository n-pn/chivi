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
      when '_' then PosTag::Litstr
      else
        char.alphanumeric? ? PosTag::Litstr : PosTag::None
      end
  end

  def initialize(@key, @val = @key, @tag = PosTag::None, @dic = 0, @idx = -1)
  end

  def blank?
    @key.empty? || @val.blank?
  end

  def set_body!(node : MtNode) : Nil
    self.body = node
    self.fix_root!(node.root?)
    node.root = self
  end

  def fix_root!(@root : MtNode?) : Nil
  end

  def prev?
    @prev.try { |x| yield x }
  end

  def succ?
    @succ.try { |x| yield x }
  end

  def set_prev!(node : MtNode) : Nil
    node.fix_prev!(@prev)
    self.fix_prev!(node)
  end

  def set_prev!(@prev : Nil) : Nil
  end

  def set_succ!(node : MtNode) : Nil
    node.fix_succ!(@succ)
    self.fix_succ!(node)
  end

  def set_succ!(@succ : Nil) : Nil
  end

  def fix_prev!(@prev : self) : Nil
    prev.succ = self
  end

  def fix_prev!(@prev : Nil) : Nil
  end

  def fix_succ!(@succ : self) : Nil
    succ.prev = self
  end

  def fix_succ!(@succ : Nil) : Nil
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

  def maybe_verb? : Bool
    succ = self
    while succ
      # puts [succ, "maybe_verb", succ.verbs?]
      case succ
      when .verbs?, .vmodals? then return true
      when .adverbs?, .comma?, pro_ints?, .conjunct?, .time?
        succ = succ.succ?
      else return false
      end
    end

    false
  end

  def maybe_adjt? : Bool
    return !@succ.try(&.maybe_verb?) if @tag.ajad?
    @tag.adjts? || @tag.adverbs? && @succ.try(&.maybe_adjt?) || false
  end

  def last_child : MtNode?
    return nil unless body = @body

    while succ = body.succ?
      body = succ
    end

    body
  end

  def starts_with?(key : String | Char)
    return @key.starts_with?(key) unless body = @body
    body.starts_with?(key)
  end

  def ends_with?(key : String | Char)
    return @key.ends_with?(key) unless child = self.last_child
    child.ends_with?(key)
  end

  def key_in?(key)
    @key.in?(key)
  end

  def key?(key : String)
    @key === key
  end

  def dig_key?(key : String | Char) : self | Nil
    return @key.includes?(key) ? self : nil unless child = @body

    while child
      child = child.succ? unless found = child.dig_key?(key)
      return found
    end
  end

  def each
    yield self unless body = @body

    while body
      yield body if body = body.succ?
    end
  end

  include MTL::Serialize
  include MTL::ApplyCap
  include MTL::PadSpace
end
