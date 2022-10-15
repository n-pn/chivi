require "./mt_node/*"
require "./txt_seg/*"

class MT::TxtSeg
  getter raw_chars = [] of Char
  getter mtl_chars = [] of Char

  @costs : Array(Int32)
  @nodes : Array(MonoNode)

  def initialize(input : String)
    @raw_chars = input.chars
    @upper = @raw_chars.size

    @costs = Array(Int32).new(@upper &+ 1, 0)
    @nodes = Array(MonoNode).new(@upper &+ 1)
    @nodes << MonoNode.new("", idx: -1)

    @keys.each_with_index do |raw_char, idx|
      mtl_char = NerHelper.fullwidth?(raw_char) ? NerHelper.to_halfwidth(raw_char) : raw_char
      @mtl_chars << mtl_char

      @nodes << init_node(raw_char, mtl_char, idx)
    end
  end

  private def init_node(raw_char : Char, mtl_char : Char, idx : Int32)
    mtl_str = mtl_char.to_s
    tag, pos = PosTag.map_punct(mtl_str)
    MonoNode.new(raw_char.to_s, mtl_str, tag: tag, pos: pos, idx: idx)
  end

  def run_ner!
    idx = 0

    while idx < @upper
      mtl_char = @mtl_chars.unsafe_fetch(idx)

      case mtl_char
      when .is_letter?
        idx = add_string(idx)
      when .is_number?
        idx = add_number(idx)
      else
        idx += 1
      end
    end
  end

  private def apply_term(term : MonoNode, idx : Int32, new_idx : Int32, size = new_idx &- idx)
    @nodes[new_idx] = term
    @costs[new_idx] = @costs.unsafe_fetch(idx) &+ MtTerm.seg_weight(size: size, rank: 1_i8)
  end

  def result
    idx = @raw_chars.size
    res = MtData.new

    while idx > 0
      node = nodes.unsafe_fetch(idx)
      idx &-= node.key.size
      res.add_node(node)
    end

    res
  end
end
