require "./vp_dict"
require "./mt_core/*"

class CV::MtCore
  class_getter hanviet_mtl : self { new([VpDict.essence, VpDict.hanviet]) }
  class_getter binh_am_mtl : self { new([VpDict.essence, VpDict.binh_am]) }
  class_getter tradsim_mtl : self { new([VpDict.tradsim]) }

  def self.generic_mtl(pdict : String = "combine", stype : String = "chivi")
    new(VpDict.for_convert(pdict, stype))
  end

  def self.convert(input : String, dname = "various") : Cvmtl
    case dname
    when "hanviet" then hanviet.translit(input).to_s
    when "binh_am" then binh_am.translit(input).to_s
    when "tradsim" then tradsim.tokenize(input.chars).to_s
    else                generic(dname).cv_plain(input).to_s
    end
  end

  def initialize(@dicts : Array(VpDict))
  end

  def translit(input : String, apply_cap : Bool = false)
    group = tokenize(input.chars)
    group.capitalize! if apply_cap
    group.pad_spaces!
  end

  def translit(input : String, cap_mode : Int32)
    tokenize(input.chars).capitalize!(cap_mode: cap_mode).pad_spaces!
  end

  def cv_plain(input : String, mode = 2, cap_mode = 1)
    tokenize(input.chars)
      .fix_grammar!(mode: mode)
      .capitalize!(cap_mode: cap_mode)
      .pad_spaces!
  end

  def cv_title_full(title : String, mode = 2)
    title, label = TextUtils.format_title(title)

    title_res = cv_title(title)
    return title_res if label.empty?

    title_res.prepend!(MtNode.new("", " - "))
    label_res = cv_title(label, mode: mode)
    label_res.concat!(title_res)
  end

  def cv_title(title : String, mode = 2)
    pre_zh, pre_vi, pad, title = MtUtil.tl_title(title)
    res = title.empty? ? MtList.new : cv_plain(title, mode: mode)

    unless pre_zh.empty?
      res.prepend!(MtNode.new(pad, title.empty? ? "" : ": "))
      res.prepend!(MtNode.new(pre_zh, pre_vi, dic: 1))
    end

    res
  end

  def tokenize(input : Array(Char)) : MtList
    nodes = [MtNode.new("", "")]
    costs = [0.0]

    input.each_with_index(1) do |char, idx|
      nodes << MtNode.new(char, idx - 1)
      costs << idx - 0.5
    end

    input.size.times do |idx|
      terms = {} of Int32 => VpTerm

      @dicts.each do |dict|
        dict.scan(input, idx) { |x| terms[x.key.size] = x unless x.empty? }
      end

      terms.each do |key, term|
        next if term.val[0]? == "[[pass]]"

        cost = costs[idx] + term.point
        jump = idx &+ key

        if cost >= costs[jump]
          costs[jump] = cost
          nodes[jump] = MtNode.new(term, idx)
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
        lst.prepend!(cur)
      else
        res.prepend!(cur)
        lst = cur
      end
    end

    res
  end

  private def can_merge?(left : MtNode, right : MtNode)
    case right.tag
    when .numlat?
      case left.tag
      when .strings?
        right.tag = left.tag
        true
      when .pdeci?  then true
      when .numlat? then true
      else               false
      end
    when .strings? then left.strings?
    when .puncts?  then left.tag == right.tag
    else                false
    end
  end
end
