require "./vp_dict"
require "./mt_core/*"

class CV::MtCore
  class_getter hanviet_mtl : self { new([VpDict.essence, VpDict.hanviet]) }
  class_getter binh_am_mtl : self { new([VpDict.essence, VpDict.binh_am]) }
  class_getter tradsim_mtl : self { new([VpDict.tradsim]) }

  def self.generic_mtl(bname : String = "combine", uname : String = "")
    dicts = [VpDict.essence, VpDict.regular, VpDict.fixture, VpDict.load(bname)]
    new(dicts, "!#{uname}")
  end

  def self.convert(input : String, dname = "various") : Cvmtl
    case dname
    when "hanviet" then hanviet.translit(input).to_s
    when "binh_am" then binh_am.translit(input).to_s
    when "tradsim" then tradsim.tokenize(input.chars).to_s
    else                generic(dname).cv_plain(input).to_s
    end
  end

  def initialize(@dicts : Array(VpDict), @uname : String = "")
  end

  def translit(input : String, apply_cap : Bool = false)
    list = tokenize(input.chars)
    list.capitalize!(cap: true) if apply_cap
    list.pad_spaces!
  end

  def cv_title_full(title : String, mode = 1)
    title, label = TextUtils.format_title(title)

    title_res = cv_title(title, offset: label.size)
    return title_res if label.empty?

    title_res.prepend!(MtNode.new("", " - ", idx: label.size))
    label_res = cv_title(label, mode: mode)
    label_res.concat!(title_res)
  end

  def cv_title(title : String, mode = 1, offset = 0)
    pre_zh, pre_vi, pad, title = MtUtil.tl_title(title)
    offset_2 = offset + pre_zh.size + pad.size

    res = title.empty? ? MtList.new : cv_plain(title, mode: mode, offset: offset_2)

    unless pre_zh.empty?
      res.prepend!(MtNode.new(pad, title.empty? ? "" : ": ", idx: offset + pre_zh.size))
      res.prepend!(MtNode.new(pre_zh, pre_vi, dic: 1, idx: offset))
    end

    res
  end

  def cv_plain(input : String, mode = 1, cap_first = true, offset = 0)
    list = tokenize(input.chars, offset: offset)
    list.fix_grammar!(mode: mode)
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
          terms[term.key.size] = {dict.dtype, term}
        end
      end

      terms.each do |key, (dic, term)|
        next if term.val[0]? == "[[pass]]"

        cost = costs[idx] + term.point
        jump = idx &+ key

        if cost >= costs[jump]
          costs[jump] = cost
          dic &+= 2 if term.is_priv
          nodes[jump] = MtNode.new(term, dic, idx + offset)
        end
      end
    end

    res = MtList.new
    idx = nodes.size - 1

    lst = nodes.unsafe_fetch(idx)
    res.prepend!(lst)
    idx -= lst.key.size

    while idx > 0
      cur = nodes.unsafe_fetch(idx)
      idx -= cur.key.size

      if can_merge?(cur, lst)
        lst.idx = cur.idx
        lst.val = cur.nhanzi? ? "#{cur.val} #{fix_val!(lst)}" : "#{cur.val}#{lst.val}"
        lst.key = "#{cur.key}#{lst.key}"
      else
        res.prepend!(cur)
        lst = cur
      end
    end

    res
  end

  private def fix_val!(node : MtNode)
    case node.key[0]?
    when '零' then node.val.sub("linh", "lẻ")
    when '一' then node.val.sub("một", "mốt")
    when '五' then node.val.sub("năm", "lăm")
    when '十' then node.val.sub("mười", "mươi")
    else          node.val
    end
  end

  private def can_merge?(left : MtNode, right : MtNode)
    case right.tag
    when .strings? then left.tag.strings?
    when .puncts?  then left.tag == right.tag
    when .nhanzi?
      return false unless left.nhanzi?
      return true unless right.key == "两"

      case left.key[-1]?
      when '一', '三' then return true
      else
        right.set!("lượng", PosTag::Qtnoun)
        false
      end
    when .ndigit?
      case left.tag
      when .pdeci?  then true
      when .ndigit? then true
      when .strings?
        right.tag = left.tag
        true
      else false
      end
    else
      false
    end
  end
end
