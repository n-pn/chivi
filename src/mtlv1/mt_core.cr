require "./vp_dict"
require "./mt_data"

class CV::MtCore
  class_getter hanviet_mtl : self { new([VpDict.essence, VpDict.hanviet]) }
  class_getter pin_yin_mtl : self { new([VpDict.essence, VpDict.pin_yin]) }
  class_getter tradsim_mtl : self { new([VpDict.tradsim]) }

  def self.generic_mtl(bname : String = "combine", uname : String = "") : self
    dicts = [VpDict.essence, VpDict.regular, VpDict.fixture, VpDict.load(bname)]
    new(dicts, "!#{uname}")
  end

  def self.load(dname : String, uname : String = "") : self
    case dname
    when "pin_yin" then pin_yin_mtl
    when "hanviet" then hanviet_mtl
    when "tradsim" then tradsim_mtl
    when .starts_with?('-')
      generic_mtl(dname, uname)
    else
      generic_mtl("combine", uname)
    end
  end

  def self.cv_pin_yin(input : String) : String
    pin_yin_mtl.translit(input).to_txt
  end

  def self.cv_hanviet(input : String, apply_cap = true) : String
    return input unless input =~ /\p{Han}/
    hanviet_mtl.translit(input, apply_cap: apply_cap).to_txt
  end

  def self.trad_to_simp(input : String) : String
    tradsim_mtl.tokenize(input.chars).to_txt
  end

  def self.convert(input : String, dname = "combine") : String
    case dname
    when "hanviet" then hanviet_mtl.translit(input).to_txt
    when "pin_yin" then pin_yin_mtl.translit(input).to_txt
    when "tradsim" then tradsim_mtl.tokenize(input.chars).to_txt
    else                generic_mtl(dname).cv_plain(input).to_txt
    end
  end

  getter dicts

  def initialize(@dicts : Array(VpDict), @uname : String = "")
  end

  def translit(input : String, apply_cap : Bool = false) : MtData
    data = tokenize(input.chars)
    data.capitalize!(cap: true) if apply_cap
    data.pad_spaces!
    data
  end

  def cv_title_full(title : String) : MtData
    title, chvol = TextUtil.format_title(title)

    mt_data = cv_title(title, offset: chvol.size)
    return mt_data if chvol.empty?

    mt_data.add_head(MtNode.new("", " - ", idx: chvol.size))
    cv_title(chvol).concat(mt_data)
  end

  def cv_title(title : String, offset = 0) : MtData
    pre_zh, pre_vi, pad, title = MtUtil.tl_title(title)
    offset_2 = offset + pre_zh.size + pad.size

    mt_data = MtData.new(MtNode.new(pre_zh, pre_vi, dic: 1, idx: offset))
    mt_data.add_tail(MtNode.new(pad, title.empty? ? "" : ": ", idx: offset + pre_zh.size))

    mt_data.concat(cv_plain(title, offset: offset_2))
  end

  def translate(input : String) : String
    cv_plain(input).to_txt
  end

  def cv_plain(input : String, cap_first = true, offset = 0) : MtData
    data = tokenize(input.chars, offset: offset)
    data.fix_grammar!
    data.capitalize!(cap: cap_first)
    data.pad_spaces!
    data
  end

  def tokenize(input : Array(Char), offset = 0) : MtData
    nodes = [MtNode.new("", "")]
    costs = [0.0]

    input.each_with_index(1) do |char, idx|
      nodes << MtNode.new(char, idx: idx - 1 + offset)
      costs << idx - 0.5
    end

    input.size.times do |idx|
      terms = {} of Int32 => Tuple(Int32, VpTerm)

      @dicts.each do |dict|
        dict.scan(input, @uname, idx) do |term|
          terms[term.key.size] = {dict.type, term}
        end
      end

      terms.each do |key, (dic, term)|
        next if term.val[0]? == "[[pass]]"

        cost = costs[idx] + term.point
        jump = idx &+ key

        if cost >= costs[jump]
          dic = term.is_priv ? dic &+ 2 : dic
          nodes[jump] = MtNode.new(term, dic, idx + offset)
          costs[jump] = cost
        end
      end
    end

    idx = nodes.size - 1
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
