class MtlV2::MTL::MtCore
  getter dicts : Array(V2Dict)

  def initialize(@dicts, @uname : String = "")
  end

  def translit(input : String, apply_cap : Bool = false) : MtData
    list = tokenize(input.chars)
    list.apply_cap!(cap: true) if apply_cap
    list
  end

  def cv_title_full(title : String) : MtData
    # tokens = TextUtil.split_spaces(title)

    # tokens.each do |token|
    #   if token.blank?
    #     output.concat!(BaseNode.new(token, " ", idx: offset))
    #     offset &+= token.size
    #   end

    title, chvol = CV::TextUtil.format_title(title)
    return cv_title(title, offset: 0) if chvol.empty?

    output = cv_title(chvol, offset: 0)
    offset = chvol.size

    title_res = cv_title(title, offset: offset)
    title_res.add_head(BaseNode.new("", " - ", idx: offset))

    output.add_tail(title_res)
  end

  def cv_title(title : String, offset = 0) : MtData
    pre_zh, pre_vi, pad, title = MtUtil.tl_title(title)
    offset_2 = offset + pre_zh.size + pad.size

    output = title.empty? ? MtData.new("") : cv_plain(title, offset: offset_2)

    unless pre_zh.empty?
      output.add_head(BaseWord.new(pad, title.empty? ? "" : ": ", idx: offset + pre_zh.size))
      output.add_head(BaseWord.new(pre_zh, pre_vi, dic: 1, idx: offset))
    end

    output
  end

  def translate(input : String) : String
    cv_plain(input).to_txt
  end

  def cv_plain(input : String, cap_first = true, offset = 0) : MtData
    list = tokenize(input.chars, offset: offset)
    list.apply_cap!(cap: cap_first)
    list.translate!
    list
  end

  def tokenize(input : Array(Char), offset = 0) : MtData
    nodes = [BaseWord.new("")]
    costs = [0]

    input.each_with_index(1) do |char, idx|
      nodes << BaseWord.new(char.to_s, idx: idx &- 1 &+ offset)
      costs << idx
    end

    input.size.times do |idx|
      terms = {} of Int32 => Tuple(Int32, V2Term)

      @dicts.each do |dict|
        dict.scan(input, @uname, idx) do |term|
          terms[term.key.size] = {dict.type, term}
        end
      end

      terms.each do |key, (dic, term)|
        cost = costs[idx] &+ term.worth
        jump = idx &+ key

        if cost >= costs[jump]
          tab = term.is_priv ? dic &+ 2 : dic
          nodes[jump] = term.node.dup!(idx + offset, tab)
          costs[jump] = cost
        end
      end
    end

    res = MtData.new
    idx = nodes.size &- 1

    while idx > 0
      cur = nodes.unsafe_fetch(idx)
      idx -= cur.key.size
      res.add_node(cur)
    end

    res
  end
end
