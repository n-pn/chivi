require "./vp_dict"
require "./mt_data"
require "./mt_core/*"

class CV::MtCore
  class_getter hanviet_mtl : self { new([VpDict.essence, VpDict.hanviet]) }
  class_getter pin_yin_mtl : self { new([VpDict.essence, VpDict.pin_yin]) }
  class_getter tradsim_mtl : self { new([VpDict.tradsim]) }

  def self.generic_mtl(bname : String = "combine",
                       uname : String = "",
                       temp : Bool = true) : self
    dicts = [VpDict.essence, VpDict.regular, VpDict.fixture, VpDict.load(bname)]
    new(dicts, uname, temp: temp)
  end

  def self.load(dname : String, uname : String = "", temp : Bool = false) : self
    case dname
    when "pin_yin" then pin_yin_mtl
    when "hanviet" then hanviet_mtl
    when "tradsim" then tradsim_mtl
    when .starts_with?('-')
      generic_mtl(dname, uname, temp: temp)
    else
      generic_mtl("combine", uname, temp: temp)
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

  def initialize(@dicts : Array(VpDict), @uname : String = "", @temp : Bool = false)
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
    return cv_plain(title, offset: offset) if pre_zh.empty?

    pre_zh += pad
    pre_vi += title.empty? ? "" : ":"

    mt_data = MtData.new(MtTerm.new(pre_zh, pre_vi, dic: 1, idx: offset))
    return mt_data if title.empty?

    mt_data.concat(cv_plain(title, offset: offset + pre_zh.size))
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

  # def greedy_scan(input : Array(Char)) : MtData

  #   nodes = [] of MtNode

  #   input.size.times do |idx|
  #     @dicts.each do |dict|

  #       dict.scan_best(input, idx) do |term|
  #         terms[term.key.size] = {dict.type, term}
  #       end
  #     end
  #   end
  # end

  def tokenize(input : Array(Char), offset = 0, mode : Int8 = 1_i8) : MtData
    nodes = [MtTerm.new("", idx: offset)]
    costs = [0]

    input.each_with_index do |char, idx|
      nodes << MtTerm.new(char, idx: idx &+ offset)
      costs << idx &+ 1
    end

    ner_idx = 0

    input.size.times do |idx|
      base_cost = costs.unsafe_fetch(idx)

      if idx >= ner_idx && (ner_term = MTL.ner_recog(input, idx, mode))
        ner_idx = idx &+ ner_term.key.size

        size = ner_term.key.size
        jump = idx &+ size
        cost = base_cost + MtUtil.cost(size, 1_i8)

        if cost > costs[jump]
          ner_term.idx = idx &+ offset
          nodes[jump] = ner_term
          costs[jump] = cost
        end
      end

      terms = {} of Int32 => Tuple(Int32, VpTerm)

      @dicts.each do |dict|
        dict.scan_best(input, idx, user: @uname, temp: @temp) do |term|
          terms[term.key.size] = {dict.type, term}
        end
      end

      terms.each do |key, (dic, term)|
        next if term.prio < 1

        cost = base_cost &+ term.cost
        jump = idx &+ key

        if cost >= costs[jump]
          nodes[jump] = MtTerm.new(term, dic &+ term._mode &* 2, idx &+ offset)
          costs[jump] = cost
        end
      end
    end

    extract_result(nodes)
  end

  def extract_result(nodes : Array(MtTerm))
    idx = nodes.size &- 1
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
