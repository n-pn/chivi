require "./m1_dict"
require "./m1_data"
require "./mt_core/*"

require "../data/v1_dict"

class M1::MtCore
  class_getter hanviet_mtl : self { new([MtDict.hanviet]) }
  class_getter pin_yin_mtl : self { new([MtDict.pin_yin]) }

  def self.generic_mtl(udic : Int32 = 0, temp : Bool = true, user : String = "") : self
    dicts = [MtDict.regular_main]

    dicts << MtDict.regular_temp if temp
    dicts << MtDict.regular_user(user) unless user.empty?

    dicts << MtDict.regular_init

    dicts << MtDict.unique_main(udic)
    dicts << MtDict.unique_temp(udic) if temp
    dicts << MtDict.unique_user(udic, user) unless user.empty?

    new(dicts)
  end

  def self.load(dname : String, temp : Bool = false, user : String = "") : self
    case dname
    when "pin_yin" then pin_yin_mtl
    when "hanviet" then hanviet_mtl
    else                generic_mtl(DbDict.get_id(dname), temp: temp, user: user)
    end
  end

  def self.cv_pin_yin(input : String) : String
    pin_yin_mtl.translit(input).to_txt
  end

  def self.cv_hanviet(input : String, apply_cap = true) : String
    return input unless input =~ /\p{Han}/
    hanviet_mtl.translit(input, apply_cap: apply_cap).to_txt
  end

  def self.convert(input : String, dname = "combine") : String
    case dname
    when "hanviet" then hanviet_mtl.translit(input).to_txt
    when "pin_yin" then pin_yin_mtl.translit(input).to_txt
    else                generic_mtl(dname).cv_plain(input).to_txt
    end
  end

  def initialize(@dicts : Array(MtDict))
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

  def tokenize(input : Array(Char), offset = 0) : MtData
    nodes = [MtTerm.new("", idx: offset)]
    costs = [0]

    input.each_with_index do |char, idx|
      nodes << MtTerm.new(char, idx: idx &+ offset)
      costs << idx &+ 1
    end

    ner_idx = 0

    input.size.times do |idx|
      base_cost = costs.unsafe_fetch(idx)

      if idx >= ner_idx && (ner_term = MTL.ner_recog(input, idx))
        ner_idx = idx &+ ner_term.key.size

        size = ner_term.key.size
        jump = idx &+ size
        cost = base_cost &+ MtTerm.cost(size, 1)

        if cost > costs[jump]
          ner_term.idx = idx &+ offset
          nodes[jump] = ner_term
          costs[jump] = cost
        end
      end

      terms = {} of Int32 => MtTerm

      @dicts.each do |dict|
        dict.scan(input, idx) do |term|
          terms[term.key.size] = term
        end
      end

      terms.each do |key, term|
        next if term.cost == 0

        cost = base_cost &+ term.cost
        jump = idx &+ key

        if cost >= costs[jump]
          costs[jump] = cost
          nodes[jump] = term.clone!(idx &+ offset)
        end
      end
    end

    extract_result(nodes)
  end

  private def extract_result(nodes : Array(MtTerm))
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
