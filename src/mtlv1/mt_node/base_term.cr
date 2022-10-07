require "./base_node"

require "../pos_tag"
require "../vp_dict/vp_term"
require "../mt_core/mt_util"
require "../../_util/text_util"

module CV::MtUtil
  COSTS = {
    0, 3, 6, 9,
    0, 14, 18, 26,
    0, 25, 31, 40,
    0, 40, 45, 55,
    0, 58, 66, 78,
  }

  def self.cost(size : Int32, prio : Int8 = 0) : Int32
    COSTS[(size &- 1) &* 4 &+ prio]? || size &* (prio &* 2 &+ 7) &* 2
  end
end

# reopen class VpTerm
class CV::VpTerm
  # auto generated fields
  getter ptag : PosTag { PosTag.init(@tags[0], @key, @vals) }
  getter cost : Int32 { MtUtil.cost(@key.size, @prio) }
end

class CV::BaseTerm < CV::BaseNode
  def self.from(term : VpTerm, dic = 0, idx = 0)
    new(term.key, term.vals[0], term.ptag, dic, idx, alt: term.vals[1]?)
  end

  def self.from(char : Char, dic = 0, idx = 0)
    str = char.to_s
    new(str, str, dic: dic, idx: idx)
  end

  getter alt : String? = nil

  def initialize(@key, @val = @key, @tag = PosTag::LitBlank,
                 @dic = 0, @idx = 0, @alt = nil)
  end

  def swap_val! : self
    @alt.try { |x| @val = x }
    self
  end

  def blank? : Bool
    @key.empty? || @val.blank?
  end

  def inactivate!
    @val = ""
    @tag = PosTag.new(@tag.tag, @tag.pos | MtlPos::Overlook)
    self
  end

  def to_txt(io : IO) : Nil
    io << @val
  end

  def to_mtl(io : IO) : Nil
    io << '\t' << @val << 'ǀ' << @dic << 'ǀ' << @idx << 'ǀ' << @key.size
  end

  def inspect(io : IO = STDOUT, pad = -1) : Nil
    io << " " * pad if pad >= 0
    io << "[#{@key}/#{@val}/#{@tag.tag}/#{@dic}/#{@idx}]"
    io << '\n' if pad >= 0
  end
end
