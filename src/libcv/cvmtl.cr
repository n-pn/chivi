require "./vdict"
require "./cvmtl/*"

class CV::Cvmtl
  class_getter hanviet : self { new(Vdict.hanviet) }
  class_getter binh_am : self { new(Vdict.binh_am) }
  class_getter tradsim : self { new(Vdict.tradsim) }

  def self.generic(bdict : String)
    new(Vdict.regular, Vdict.load(bdict))
  end

  def self.convert(input : String, dname = "various") : Cvmtl
    case dname
    when "hanviet" then hanviet.translit(input).to_s
    when "binh_am" then binh_am.translit(input).to_s
    when "tradsim" then tradsim.tokenize(input.chars).to_s
    else                generic(dname).cv_plain(input).to_s
    end
  end

  # def self.init(dname : String)
  #   case dname
  #   when "hanviet" then hanviet
  #   when "binh_am" then binh_am
  #   when "tradsim" then tradsim
  #   else                generic(dname)
  #   end
  # end

  def initialize(@rdict : Vdict, @bdict : Vdict? = nil)
  end

  def translit(input : String, apply_cap : Bool = false)
    group = tokenize(input.chars)
    group.capitalize! if apply_cap
    group.pad_spaces!
  end

  def tl_plain(input : String) : String
    cv_plain(input).to_s
  end

  def tl_title(input : String) : String
    cv_title(input).to_s
  end

  def cv_plain(input : String)
    tokenize(input.chars).fix_grammar!.capitalize!.pad_spaces!
  end

  def cv_title_full(title : String)
    title, label = TextUtils.format_title(title)

    title_res = cv_title(title)
    return title_res if label.empty?

    label_res = cv_title(label)
    label_res.data << CvNode.new("", " - ")
    label_res.data.concat(title_res.data)

    label_res
  end

  NUMS = "零〇一二两三四五六七八九十百千"
  SEPS = ".，,、：:"

  LABEL_RE_1 = /^(第?([#{NUMS}]+|\d+)([集卷]))([#{SEPS}\s]*)(.*)$/

  TITLE_RE_1 = /^(第.*?([#{NUMS}]+|\d+).*?([章节幕回折]))(.*?\d+\.\s)(.+)/
  TITLE_RE_2 = /^(.*?([#{NUMS}]+|\d+).*?([章节幕回折]))([#{SEPS}\s]*)(.*)$/

  TITLE_RE_3 = /^(\d+)([#{SEPS}\s]*)(.*)$/
  TITLE_RE_4 = /^楔子(\s+)(.+)$/

  def cv_title(title : String)
    pre, pad = nil, ""

    if match = LABEL_RE_1.match(title) || TITLE_RE_1.match(title) || TITLE_RE_2.match(title)
      _, group, num, lbl, pad, title = match
      pre = CvNode.new(group, "#{vi_label(lbl)} #{CvUtil.to_integer(num)}", 1)
    elsif match = TITLE_RE_3.match(title)
      _, num, pad, title = match
      pre = CvNode.new(num, num, 1)
    elsif match = TITLE_RE_4.match(title)
      _, pad, title = match
      pre = CvNode.new("楔子", "Phần đệm", 1)
    end

    res = title.empty? ? Deque(CvNode).new : cv_plain(title).data

    if pre
      res.unshift(CvNode.new(pad, title.empty? ? "" : ": "))
      res.unshift(pre)
    end

    Cline.new(res)
  end

  private def vi_label(lbl = "")
    case lbl
    when "章" then "Chương"
    when "卷" then "Quyển"
    when "集" then "Tập"
    when "节" then "Tiết"
    when "幕" then "Màn"
    when "回" then "Hồi"
    when "折" then "Chiết"
    else          "Chương"
    end
  end

  def tokenize(input : Array(Char)) : Cline
    nodes = [CvNode.new("", "")]
    costs = [0.0]

    input.each_with_index(1) do |char, idx|
      norm = CvUtil.normalize(char)
      nodes << CvNode.new(char.to_s, norm.to_s, alnum?(norm) ? 1 : 0)
      costs << idx.to_f
    end

    input.size.times do |idx|
      terms = {} of Int32 => Vterm

      @rdict.scan(input, idx) { |x| terms[x.key.size] = x unless x.empty? }

      @bdict.try do |dict|
        dict.scan(input, idx) { |x| terms[x.key.size] = x unless x.empty? }
      end

      terms.each do |key, term|
        cost = costs[idx] + term.point
        jump = idx &+ key

        if cost >= costs[jump]
          costs[jump] = cost
          nodes[jump] = CvNode.new(term)
        end
      end
    end

    extract_best(nodes)
  end

  private def alnum?(char : Char)
    char == '_' || char.ascii_number? || char.letter?
  end

  private def extract_best(nodes : Array(CvNode))
    ary = Deque(CvNode).new
    idx = nodes.size - 1

    while idx > 0
      curr = nodes.unsafe_fetch(idx)
      idx -= curr.key.size

      if curr.dic == 0
        while idx > 0
          node = nodes.unsafe_fetch(idx)
          break if node.dic > 0 || curr.key[0] != node.key[0]

          curr.combine!(node)
          idx -= node.key.size
        end
      elsif curr.dic == 1
        while idx > 0
          node = nodes.unsafe_fetch(idx)
          break if node.dic > 1
          break if node.dic == 0 && !node.special_mid_char?

          curr.combine!(node)
          idx -= node.key.size
        end

        if (last = ary.last?) && last.special_end_char?
          last.combine!(curr)
          last.dic = 1
          next
        end

        # handling +1+1+1 or -1-1-1
        case curr.key[0]?
        when '+' then curr.val = curr.key.gsub("+", " +").strip
        when '-' then curr.val = curr.key.gsub("-", " -").strip
        end
      end

      ary.unshift(curr)
    end

    Cline.new(ary)
  end
end
