require "./engine/*"
require "../_util/text_util"

class MT::Engine
  def initialize(book : String, theme : String? = nil, user : String? = nil)
    @dicts = MtDict.new(book: book, theme: theme, user: user)
  end

  def cv_title_full(title : String) : MtData
    title, chvol = TextUtil.format_title(title)

    mt_data = cv_title(title, offset: chvol.size)
    return mt_data if chvol.empty?

    tag, pos = PosTag::Empty
    pos |= MtlPos.flags(CapAfter, NoSpaceL)

    mt_node = MonoNode.new("", "-", tag, pos, idx: chvol.size)
    mt_data.add_head(mt_node)

    cv_title(chvol).concat(mt_data)
  end

  def cv_title(title : String, offset = 0) : MtData
    pre_zh, pre_vi, pad, title = MtUtil.tl_title(title)
    return cv_plain(title, offset: offset) if pre_zh.empty?

    pre_zh += pad
    pre_vi += title.empty? ? "" : ":"

    tag, pos = PosTag::LitTrans
    pos |= MtlPos.flags(CapAfter, NoSpaceR)
    mt_head = MonoNode.new(pre_zh, pre_vi, tag, pos, dic: 1, idx: offset)

    mt_data = MtData.new
    mt_data.add_head(mt_head)

    return mt_data if title.empty?
    mt_data.concat(cv_plain(title, offset: offset + pre_zh.size))
  end

  def cv_plain(input : String, cap_first = true, offset = 0) : MtData
    data = tokenize(input.chars, offset: offset)
    data.fix_grammar!
    data.apply_cap!(cap: cap_first)
    data
  end

  def tokenize(input : Array(Char), offset = 0) : MtData
    nodes = [MonoNode.new("", idx: offset)]
    costs = [0]

    input.each_with_index do |char, idx|
      nodes << MonoNode.new(char, idx: idx &+ offset)
      costs << idx &+ 1
    end

    ner_idx = 0

    input.size.times do |idx|
      base_cost = costs.unsafe_fetch(idx)

      if idx >= ner_idx && (ner_term = Core.ner_recog(input, idx))
        ner_idx = idx &+ ner_term.key.size

        size = ner_term.key.size
        jump = idx &+ size
        cost = base_cost + MtTerm.seg_weight(size, 1_i8)

        if cost > costs[jump]
          ner_term.offset_idx!(offset)
          nodes[jump] = ner_term
          costs[jump] = cost
        end
      end

      @dicts.scan(input, idx) do |term, key_size, dict_id|
        cost = base_cost &+ term.seg
        jump = idx &+ key_size

        if cost >= costs[jump]
          nodes[jump] = MonoNode.new(term, dic: dict_id, idx: idx &+ offset)
          costs[jump] = cost
        end
      end
    end

    extract_result(nodes)
  end

  def extract_result(nodes : Array(MonoNode))
    idx = nodes.size &- 1
    res = MtData.new

    while idx > 0
      cur = nodes.unsafe_fetch(idx)
      idx -= cur.key.size
      res.add_node(cur)
    end

    res
  end
end
