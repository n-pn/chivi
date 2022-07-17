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
    data = tradsim_mtl.tokenize(input.chars)

    String.build do |io|
      head = data.head
      while head
        io << head.val
        head = head.succ?
      end
    end
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
    data.apply_cap!(cap: true) if apply_cap
    data
  end

  def cv_title_full(title : String) : MtData
    title, chvol = TextUtil.format_title(title)

    mt_data = cv_title(title, offset: chvol.size)
    return mt_data if chvol.empty?

    mt_data.add_head(MtTerm.new("", " - ", idx: chvol.size))
    cv_title(chvol).concat(mt_data)
  end

  def cv_title(title : String, offset = 0) : MtData
    pre_zh, pre_vi, pad, title = MtUtil.tl_title(title)
    offset_2 = offset + pre_zh.size + pad.size

    mt_data = MtData.new(MtTerm.new(pre_zh, pre_vi, dic: 1, idx: offset))
    mt_data.add_tail(MtTerm.new(pad, title.empty? ? "" : ": ", idx: offset + pre_zh.size))

    mt_data.concat(cv_plain(title, offset: offset_2))
  end

  def translate(input : String) : String
    cv_plain(input).to_txt
  end

  def cv_plain(input : String, cap_first = true, offset = 0) : MtData
    data = tokenize(input.chars, offset: offset)
    data.fix_grammar!
    data.apply_cap!(cap: cap_first)
    data
  end

  def tokenize(input : Array(Char), offset = 0) : MtData
    nodes = [MtTerm.new("", idx: offset)]
    costs = [0]

    input.each_with_index do |char, idx|
      nodes << MtTerm.new(char, idx: idx &+ offset)
      costs << idx
    end

    input.size.times do |idx|
      base_cost = costs.unsafe_fetch(idx)

      naive_ner(input, idx, offset).try do |term|
        size = term.key.size
        jump = idx &+ size
        cost = base_cost + VpTerm.worth(size, 0)

        if cost > costs[jump]
          nodes[jump] = term
          costs[jump] = cost
        end
      end

      terms = {} of Int32 => Tuple(Int32, VpTerm)

      @dicts.each do |dict|
        dict.scan(input, @uname, idx) do |term|
          next if term.val[0]? == "[[pass]]"
          terms[term.key.size] = {dict.type, term}
        end
      end

      terms.each do |key, (dic, term)|
        cost = base_cost &+ term.point
        jump = idx &+ key

        if cost >= costs[jump]
          dic = term.is_priv ? dic &+ 2 : dic
          nodes[jump] = MtTerm.new(term, dic, idx + offset)
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

  def naive_ner(input : Array(Char), index = 0, offset = 0)
    key_io = String::Builder.new
    chars = digits = puncts = spaces = caps = letters = 0

    input[index..].each do |char|
      case char
      when .number?
        digits += 1
      when .ascii_letter?
        letters += 1
        caps += 1 if char.uppercase?
      when '_'
        letters += 1
      when ' '
        spaces += 1
      when ':', '/', '.', '?', '@', '=', '%', '+', '-', '~'
        break unless chars > 0
        puncts += 1
      else
        break
      end

      chars += 1
      key_io << char
    end

    return if chars == 0
    key = key_io.to_s

    case
    when letters == chars then tag = PosTag::Noun
    when letters > 0      then tag = litstr_tag(key, spaces, caps, puncts)
    when puncts == 0      then tag = PosTag::Ndigit
    else                       tag = PosTag.from_numlit(key)
    end

    MtTerm.new(key, val: key, tag: tag, idx: index + offset, dic: 0)
  end

  def litstr_tag(key : String, spaces = 0, caps = 0, puncts = 0)
    case
    when spaces > 0  then PosTag::Litstr
    when caps > 0    then PosTag::Nother
    when puncts == 0 then PosTag::Nother
    else
      key =~ /https?\:|www\./ ? PosTag::Urlstr : PosTag::Litstr
    end
  end
end
