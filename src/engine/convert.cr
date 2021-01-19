require "./vp_dict"
require "./convert/*"

class CV::Convert
  class_getter hanviet : self { new(VpDict.hanviet) }
  class_getter binh_am : self { new(VpDict.binh_am) }
  class_getter tradsim : self { new(VpDict.tradsim) }

  def self.generic(bdict : String)
    new(VpDict.regular, VpDict.load(bdict))
  end

  def self.convert(input : String, dname = "various")
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

  def initialize(@rdict : VpDict, @bdict : VpDict? = nil)
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

  LABEL_RE_1 = /^(第?([零〇一二两三四五六七八九十百千]+|\d+)([集卷]))([,.:\s]*)(.*)$/

  TITLE_RE_1 = /^(第(.+)([章节幕回折])\s\d+\.)(\s)(.+)/
  TITLE_RE_2 = /^(第?([零〇一二两三四五六七八九十百千]+|\d+)([章节幕回]))([,.:\s]*)(.*)$/

  TITLE_RE_3 = /^((\d+)([,.:]))(\s*)(.+)$/
  TITLE_RE_4 = /^楔子(\s+)(.+)$/

  def cv_title(title : String)
    res = [] of CvEntry

    unless title.empty?
      if match = TITLE_RE_1.match(title) || TITLE_RE_2.match(title)
        _, group, chidx, label, trash, title = match

        num = CvUtils.to_integer(chidx)
        res << CvEntry.new(group, "#{vi_label(label)} #{num}", 1)

        if !title.empty?
          res << CvEntry.new(trash, ": ", 0)
        elsif !trash.empty?
          res << CvEntry.new(trash, "", 0)
        end
      elsif match = TITLE_RE_3.match(title)
        _, group, chidx, label, trash, title = match
        res << CvEntry.new(group, "#{chidx}#{label}", 1)

        if !title.empty?
          res << CvEntry.new(trash, " ", 0)
        elsif !trash.empty?
          res << CvEntry.new(trash, "", 0)
        end
      elsif match = TITLE_RE_4.match(title)
        _, trash, title = match
        res << CvEntry.new("楔子", "Phần đệm", 1)

        if !title.empty?
          res << CvEntry.new(trash, ": ", 0)
        elsif !trash.empty?
          res << CvEntry.new(trash, "", 0)
        end
      end

      title.split(/\s+/).each_with_index do |text, idx|
        res << CvEntry.new(" ", " ", 0) if idx > 0
        res.concat(cv_plain(text).data)
      end
    end

    CvGroup.new(res)
  end

  private def vi_label(label = "")
    case label
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

  def tokenize(chars : Array(Char)) : CvGroup
    tokenizer = Tokenizer.new(chars)

    chars.size.times do |idx|
      tokenizer.scan(@rdict, idx)
      tokenizer.scan(@bdict.not_nil!, idx) if @bdict
    end

    tokenizer.to_group
  end

  ######################

  class Tokenizer
    def initialize(@input : Array(Char))
      @nodes = [CvEntry.new("", "")]
      @costs = [0.0]

      @input.each_with_index(1) do |char, idx|
        norm = CvUtils.normalize(char)
        @nodes << CvEntry.new(char.to_s, norm.to_s, alnum?(norm) ? 1 : 0)
        @costs << idx.to_f
      end
    end

    private def alnum?(char : Char)
      char == '_' || char.ascii_number? || char.letter?
    end

    def scan(dict : VpDict, idx : Int32 = 0)
      dict.scan(@input, idx) do |entry|
        next if entry.empty?

        cost = @costs[idx] + entry.worth
        jump = idx &+ entry.key.size

        if cost > @costs[jump]
          @costs[jump] = cost
          @nodes[jump] = CvEntry.new(entry)
        end
      end
    end

    def to_group : CvGroup
      ary = [] of CvEntry
      idx = @nodes.size - 1

      while idx > 0
        curr = @nodes.unsafe_fetch(idx)
        idx -= curr.key.size

        if curr.dic == 0
          while idx > 0
            node = @nodes.unsafe_fetch(idx)
            break if node.dic > 0 || curr.key[0] != node.key[0]

            curr.combine!(node)
            idx -= node.key.size
          end
        elsif curr.dic == 1
          while idx > 0
            node = @nodes.unsafe_fetch(idx)
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
        end

        ary << curr
      end

      CvGroup.new(ary.reverse)
    end
  end
end
