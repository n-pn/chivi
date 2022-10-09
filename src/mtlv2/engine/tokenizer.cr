require "../mt_node/*"

struct Char
  def fullwidth?
    (self.ord & 0xff00) == 0xff00
  end

  def fullwidth
    (self.ord + 0xfee0).chr
  end

  def halfwidth
    (self.ord - 0xfee0).chr
  end

  def is_number?
    self.ord > 0x2F && self.ord < 0x3A
  end

  def is_letter?
    'a' <= self <= 'z' || 'A' <= self <= 'Z'
  end

  def to_int
    self.ord - 0x30
  end
end

class MTL::Tokenizer
  getter raw_chars = [] of Char
  getter mtl_chars = [] of Char

  @costs : Array(Int32)
  @terms : Array(BaseTerm)

  def initialize(input : String)
    @raw_chars = input.chars
    @limit = @raw_chars.size

    @costs = Array(Int32).new(@limit &+ 1, 0)
    @terms = Array(BaseTerm).new(@limit &+ 1)
    @terms << BaseTerm.new("", idx: -1)

    @keys.each_with_index do |raw_char, idx|
      mtl_char = raw_char.fullwidth? ? raw_char.halfwidth : raw_char
      @mtl_chars << mtl_char
      @terms << BaseTerm.new(raw_char.to_s, mtl_char.to_s, idx: idx)
    end
  end

  def add_named_entities
    idx = 0

    while idx < @limit
      mtl_char = @raw_chars.unsafe_fetch(idx)

      case mtl_char
      when .is_letter?
        idx = add_string_entity(idx)
      when .is_number?
        idx = add_number_entity(idx)
      else
        idx += 1
      end
    end
  end

  private def apply_term(term : BaseTerm, idx : Int32, new_idx : Int32, size = new_idx &- idx)
    @nodes[new_idx] = term
    @costs[new_idx] = @costs.unsafe_fetch(idx) &+ MtUtil.cost(size, 1_i8)
  end

  def result
    idx = @raw_chars.size

    output = [] of BaseTerm

    idx = nodes.size &- 1
    cur = nodes.unsafe_fetch(idx)
    idx -= cur.key.size

    res = MtData.new(cur)

    while idx > 0
      cur = nodes.unsafe_fetch(idx)
      idx -= cur.key.size
      res.add_node(cur)
    end

    res
  end
end
