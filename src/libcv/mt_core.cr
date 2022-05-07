require "./vp_dict"
require "./mt_core/*"

class CV::MtCore
  class_getter hanviet_mtl : self { new([VpDict.essence, VpDict.hanviet]) }
  class_getter pin_yin_mtl : self { new([VpDict.essence, VpDict.pin_yin]) }
  class_getter tradsim_mtl : self { new([VpDict.tradsim]) }

  def self.generic_mtl(bname : String = "combine", uname : String = "")
    dicts = [VpDict.essence, VpDict.regular, VpDict.fixture, VpDict.load(bname)]
    new(dicts, "!#{uname}")
  end

  def self.load(dname : String, uname : String = "")
    case dname
    when "pin_yin" then pin_yin_mtl
    when "hanviet" then hanviet_mtl
    when "tradsim" then tradsim_mtl
    when "combine", .starts_with?('-')
      generic_mtl(dname, uname)
    else generic_mtl("combine", uname)
    end
  end

  def self.cv_pin_yin(input : String)
    pin_yin_mtl.translit(input).to_s
  end

  def self.cv_hanviet(input : String, apply_cap = true)
    return input unless input =~ /\p{Han}/
    hanviet_mtl.translit(input, apply_cap: apply_cap).to_s
  end

  def self.trad_to_simp(input : String) : String
    tradsim_mtl.tokenize(input.chars).to_s
  end

  def self.convert(input : String, dname = "combine") : String
    case dname
    when "hanviet" then hanviet_mtl.translit(input).to_s
    when "pin_yin" then pin_yin_mtl.translit(input).to_s
    when "tradsim" then tradsim_mtl.tokenize(input.chars).to_s
    else                generic_mtl(dname).cv_plain(input).to_s
    end
  end

  getter dicts

  def initialize(@dicts : Array(VpDict), @uname : String = "")
  end

  def translit(input : String, apply_cap : Bool = false)
    list = tokenize(input.chars)
    list.capitalize!(cap: true) if apply_cap
    list.pad_spaces!
  end

  def cv_title_full(title : String)
    title, label = TextUtil.format_title(title)

    title_res = cv_title(title, offset: label.size)
    return title_res if label.empty?

    title_res.prepend!(MtNode.new("", " - ", idx: label.size))
    label_res = cv_title(label)
    label_res.concat!(title_res)
  end

  def cv_title(title : String, offset = 0)
    pre_zh, pre_vi, pad, title = MtUtil.tl_title(title)
    offset_2 = offset + pre_zh.size + pad.size

    res = title.empty? ? MtList.new : cv_plain(title, offset: offset_2)

    unless pre_zh.empty?
      res.prepend!(MtNode.new(pad, title.empty? ? "" : ": ", idx: offset + pre_zh.size))
      res.prepend!(MtNode.new(pre_zh, pre_vi, dic: 1, idx: offset))
    end

    res
  end

  def translate(input : String)
    cv_plain(input).to_s
  end

  def cv_plain(input : String, cap_first = true, offset = 0)
    list = tokenize(input.chars, offset: offset)
    list.fix_grammar!
    list.capitalize!(cap: cap_first)
    list.pad_spaces!
  end

  def tokenize(input : Array(Char), offset = 0) : MtList
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

    res = MtList.new
    idx = nodes.size - 1

    lst = nodes.unsafe_fetch(idx)
    res.prepend!(lst)
    idx -= lst.key.size

    in_quote = false

    while idx > 0
      cur = nodes.unsafe_fetch(idx)
      idx -= cur.key.size

      if can_merge?(cur, lst)
        lst.idx = cur.idx

        lst.val = should_space?(cur, lst) ? "#{cur.val} #{fix_val!(cur, lst)}" : "#{cur.val}#{lst.val}"
        lst.key = "#{cur.key}#{lst.key}"
      else
        if cur.key == "\""
          cur.val = in_quote ? "“" : "”"
          cur.tag = PosTag.parse_punct(cur.val)
          in_quote = !in_quote
        end

        res.prepend!(cur)
        lst = cur
      end
    end

    res
  end

  @[AlwaysInline]
  def should_space?(left : MtNode, right : MtNode)
    left.nhanzi? || right.nhanzi?
  end

  private def fix_val!(left : MtNode, right : MtNode)
    val = right.val
    case right.key[0]?
    when '五'
      left.key.ends_with?('十') ? val.sub("năm", "lăm") : val
    when '十'
      return val unless left.key =~ /[一二两三四五六七八九]$/
      val.sub("mười một", "mươi mốt").sub("mười", "mươi")
    when '零' then val.sub("linh", "lẻ")
    else          val
    end
  end

  private def can_merge?(left : MtNode, right : MtNode)
    case right.tag
    when .puncts? then left.tag == right.tag
    when .litstr? then left.tag.litstr? || left.tag.ndigit?
    when .ndigit?
      case left.tag
      when .litstr?
        right.tag = left.tag
        true
      when .pdeci?  then true
      when .ndigit? then true
      else               false
      end
    when .nhanzi?
      return false unless left.numbers?
      return true unless right.key == "两"
      right.set!("lượng", PosTag::Qtnoun)
      false
    else
      false
    end
  end
end