require "./vp_dict"
require "./mt_core/*"

class CV::MtCore
  class_getter hanviet_mtl : self { new([VpDict.essence, VpDict.hanviet]) }
  class_getter binh_am_mtl : self { new([VpDict.essence, VpDict.binh_am]) }
  class_getter tradsim_mtl : self { new([VpDict.tradsim]) }

  def self.generic_mtl(bdict : String)
    new([VpDict.essence, VpDict.regular, VpDict.load(bdict), VpDict.fixture])
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

  def cv_plain(input : String)
    tokenize(input.chars)
      .fix_grammar!
      .capitalize!
      .pad_spaces!
  end

  def cv_title_full(title : String)
    title, label = TextUtils.format_title(title)

    title_res = cv_title(title)
    return title_res if label.empty?

    title_res.prepend!(MtNode.new("", " - "))
    label_res = cv_title(label)
    label_res.concat!(title_res)
  end

  def cv_title(title : String)
    pre_zh, pre_vi, pad, title = MtUtil.tl_title(title)
    res = title.empty? ? MtList.new : cv_plain(title)

    unless pre_zh.empty?
      res.prepend!(MtNode.new(pad, title.empty? ? "." : ": "))
      res.prepend!(MtNode.new(pre_zh, pre_vi, dic: 1))
    end

    res
  end

  def tokenize(input : Array(Char)) : MtList
    nodes = [MtNode.new("", "")]
    costs = [0.0]

    input.each_with_index(1) do |char, idx|
      nodes << MtNode.new(char.to_s, char.to_s)
      costs << idx - 0.5
    end

    input.size.times do |idx|
      terms = {} of Int32 => VpTerm

      @dicts.each do |dict|
        dict.scan(input, idx) { |x| terms[x.key.size] = x unless x.empty? }
      end

      terms.each do |key, term|
        cost = costs[idx] + term.point
        jump = idx &+ key

        if cost >= costs[jump]
          costs[jump] = cost
          nodes[jump] = MtNode.new(term)
        end
      end
    end

    res = MtList.new
    idx = nodes.size - 1

    while idx > 0
      node = nodes.unsafe_fetch(idx)
      idx -= node.key.size

      if (prev = res.first?) && node.similar?(prev)
        prev.absorb_similar!(node)
      else
        res.prepend!(node)
      end
    end

    res
  end
end
