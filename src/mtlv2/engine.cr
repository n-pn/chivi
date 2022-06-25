require "./v2dict"
require "./engine/*"
require "./engine/grammar/*"
require "./engine/finalize/*"

class MtlV2::Engine
  class_getter hanviet_mtl : self { new([V2Dict.essence, V2Dict.hanviet]) }
  class_getter pin_yin_mtl : self { new([V2Dict.essence, V2Dict.pin_yin]) }
  class_getter tradsim_mtl : self { new([V2Dict.tradsim]) }

  def self.generic_mtl(bname : String = "combine", uname : String = "") : self
    dicts = [V2Dict.essence, V2Dict.regular, V2Dict.fixture, V2Dict.load(bname)]
    new(dicts, "!#{uname}")
  end

  def self.load(dname : String, uname : String = "") : self
    case dname
    when "pin_yin" then pin_yin_mtl
    when "hanviet" then hanviet_mtl
    when "tradsim" then tradsim_mtl
    when "combine", .starts_with?('-')
      generic_mtl(dname, uname)
    else generic_mtl("combine", uname)
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

  ############

  getter dicts : Array(V2Dict)

  def initialize(@dicts, @uname : String = "")
  end

  def translit(input : String, apply_cap : Bool = false) : AST::BaseList
    list = tokenize(input.chars)
    list.capitalize!(cap: true) if apply_cap
    # list.pad_spaces!
    list
  end

  def cv_title_full(title : String) : AST::BaseList
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

  def cv_title(title : String, offset = 0) : AST::BaseList
    pre_zh, pre_vi, pad, title = MtUtil.tl_title(title)
    offset_2 = offset + pre_zh.size + pad.size

    output = title.empty? ? AST::BaseList.new("") : cv_plain(title, offset: offset_2)

    unless pre_zh.empty?
      output.add_head(AST::BaseNode.new(pad, title.empty? ? "" : ": ", idx: offset + pre_zh.size))
      output.add_head(AST::BaseNode.new(pre_zh, pre_vi, dic: 1, idx: offset))
    end

    output
  end

  def translate(input : String) : String
    cv_plain(input).to_txt
  end

  def cv_plain(input : String, cap_first = true, offset = 0) : AST::BaseList
    list = tokenize(input.chars, offset: offset)
    list.fold_inner!
    list.capitalize!(cap: cap_first)
    # list.pad_spaces!
    list
  end

  def tokenize(input : Array(Char), offset = 0) : AST::BaseList
    nodes = [AST::BaseNode.new("")]
    costs = [0]

    input.each_with_index(1) do |char, idx|
      nodes << AST::BaseNode.new(char, idx: idx &- 1 &+ offset)
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
          dic = term.is_priv ? dic &+ 2 : dic
          nodes[jump] = term.node.dup!(idx + offset, dic)
          costs[jump] = cost
        end
      end
    end

    res = AST::BaseList.new("", idx: 0)
    idx = nodes.size &- 1

    lst = nodes.unsafe_fetch(idx)
    res.add_head(lst)

    idx -= lst.key.size

    # in_quote = false

    while idx > 0
      cur = nodes.unsafe_fetch(idx)
      idx -= cur.key.size
      res.add_head(cur)

      # if can_merge?(cur, lst)
      #   lst.idx = cur.idx

      #   lst.val = should_space?(cur, lst) ? "#{cur.val} #{fix_val!(cur, lst)}" : "#{cur.val}#{lst.val}"
      #   lst.key = "#{cur.key}#{lst.key}"
      # else
      #   if cur.key == "\""
      #     cur.val = in_quote ? "“" : "”"
      #     cur.tag = PosTag.parse_punct(cur.val)
      #     in_quote = !in_quote
      #   end

      #   res.add_head(cur)
      #   lst = cur
      # end
    end

    res
  end

  # @[AlwaysInline]
  # def should_space?(left : AST::BaseNode, right : AST::BaseNode) : Bool
  #   left.nhanzi? || right.nhanzi?
  # end

  # private def fix_val!(left : AST::BaseNode, right : AST::BaseNode)
  #   val = right.val
  #   case right.key[0]?
  #   when '五'
  #     left.key.ends_with?('十') ? val.sub("năm", "lăm") : val
  #   when '十'
  #     return val unless left.key =~ /[一二两三四五六七八九]$/
  #     val.sub("mười một", "mươi mốt").sub("mười", "mươi")
  #   when '零' then val.sub("linh", "lẻ")
  #   else          val
  #   end
  # end

  # private def can_merge?(left : AST::BaseNode, right : AST::BaseNode) : Bool
  #   case right
  #   when .puncts? then left.tag == right.tag
  #   when .litstr? then left.litstr? || left.ndigit?
  #   when .ndigit?
  #     case left
  #     when .litstr?
  #       right.tag = left.tag
  #       true
  #     when .pdeci?  then true
  #     when .ndigit? then true
  #     else               false
  #     end
  #   when .nhanzi?
  #     return false unless left.nhanzi?
  #     return true unless right.key == "两" && right.succ? { |x| !x.nominal? }
  #     right.set!("lượng", PosTag::Qtnoun)
  #     false
  #   else
  #     false
  #   end
  # end
end
