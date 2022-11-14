require "./mt_node/**"
require "./txt_seg/**"
require "../cv_data/mt_term"

class MT::TxtSeg
  @raw_chars = [] of Char
  @mtl_chars = [] of Char

  @costs : Array(Int32)
  @nodes : Array(MonoNode)

  def initialize(input : String)
    @raw_chars = input.chars
    @upper = @raw_chars.size

    @costs = Array(Int32).new(@upper &+ 1, 0)
    @nodes = Array(MonoNode).new(@upper &+ 1)
    @nodes << MonoNode.new("", idx: -1)

    @raw_chars.each_with_index do |raw_char, idx|
      mtl_char = CharUtil.fullwidth?(raw_char) ? CharUtil.to_halfwidth(raw_char) : raw_char
      @mtl_chars << mtl_char
      @nodes << init_node(raw_char, mtl_char, idx)
    end
  end

  private def init_node(raw_char : Char, mtl_char : Char, idx : Int32)
    mtl_str = mtl_char.to_s
    tag = PosTag.map_puncts(mtl_str)
    pos = PosTag.map_pos(tag)
    MonoNode.new(raw_char.to_s, mtl_str, tag: tag, pos: pos, idx: idx)
  end

  def feed_dict!(dicts : MtDict, offset = 0)
    ner_idx = 0

    0.upto(@upper &- 1) do |idx|
      base_cost = @costs.unsafe_fetch(idx)

      if (idx >= ner_idx) && (ner_node = run_ner(idx, offset: offset))
        wlen = ner_node.key.size
        ner_idx = idx &+ wlen
        @nodes[ner_idx] = ner_node
        @costs[ner_idx] = base_cost &+ MtTerm.seg_weight(wlen: wlen, wseg: 2) &- 1
      end

      dicts.scan(@mtl_chars, idx) do |term, key_size, dict_id|
        cost = base_cost &+ term.seg
        jump = idx &+ key_size

        if cost >= @costs.unsafe_fetch(jump)
          @costs[jump] = cost

          @nodes[jump] = MonoNode.new(
            key: term.key, val: term.val, tag: term.tag, pos: term.pos,
            dic: dict_id, idx: idx &+ offset, alt: term.alt,
          )
        end
      end
    end
  end

  HANNUM_CHARS = {'一', '两', '二', '三', '四', '五', '六', '七', '八', '九', '十', '百', '千', '万', '亿', '兆'}

  private def run_ner(idx = 0, offset : Int32 = 0) : MonoNode?
    case @mtl_chars.unsafe_fetch(idx)
    when .ascii_letter?
      new_idx, tag, val = scan_string(idx)
    when .ascii_number?
      new_idx, tag, val = scan_ndigit(idx)
    when .in?(HANNUM_CHARS)
      new_idx, tag, val = scan_hannum(idx)
    when '几'
      idx += 1
      next_char = @mtl_chars.unsafe_fetch(idx)
      return unless next_char.in?(HANNUM_CHARS)

      new_idx, tag, val = scan_hannum(idx, "mấy ")
      idx -= 1
    when '第'
      idx += 1

      next_char = @mtl_chars.unsafe_fetch(idx)
      return unless next_char.in?(HANNUM_CHARS)

      new_idx, _tag, val = scan_hannum(idx)
      tag = MtlTag::Ordinal
      val = "thứ " + val
      idx -= 1
    else
      return
    end

    key = @raw_chars[idx...new_idx].join
    val ||= @mtl_chars[idx...new_idx].join

    MonoNode.new(key, val, tag: tag, idx: idx &+ offset, dic: 2)
  end

  def result : MtData
    idx = @upper
    res = MtData.new

    while idx > 0
      node = @nodes.unsafe_fetch(idx)
      idx &-= node.key.size
      res.add_node(node)
    end

    res
  end
end
