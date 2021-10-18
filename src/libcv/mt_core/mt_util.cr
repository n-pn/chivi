module CV::MtUtil
  extend self

  # convert chinese numbers to latin numbers
  # TODO: Handle bigger numbers
  def to_integer(str : String) : Int64
    str.to_i64?.try { |x| return x } # return early if input is an ascii number

    res = 0_i64
    mod = 1_i64
    acc = 0_i64

    str.chars.reverse_each do |char|
      int = to_integer(char)

      case char
      when '万', '千', '百', '十'
        res += acc
        mod = int if mod < int
        acc = int
      else
        res += int * mod
        mod *= 10
        acc = 0
      end
    end

    res + acc
  rescue err
    puts str
    0_i64
  end

  # :ditto:
  def to_integer(char : Char)
    case char
    when '零' then 0
    when '〇' then 0
    when '一' then 1
    when '两' then 2
    when '二' then 2
    when '三' then 3
    when '四' then 4
    when '五' then 5
    when '六' then 6
    when '七' then 7
    when '八' then 8
    when '九' then 9
    when '十' then 10
    when '百' then 100
    when '千' then 1000
    when '万' then 10000
    when .ascii_number?
      char.to_i
    else
      raise ArgumentError.new("Unknown char: #{char}")
    end
  end

  NUMS = "零〇一二两三四五六七八九十百千"
  SEPS = ".，,、：:"

  LABEL_RE_1 = /^(【?第?([#{NUMS}]+|\d+)([集卷])】?)([#{SEPS}\s]*)(.*)$/

  TITLE_RE_1 = /^(第.*?([#{NUMS}]+|\d+).*?([章节幕回折]))(.*?\d+\.\s)(.+)/
  TITLE_RE_2 = /^(.*?([#{NUMS}]+|\d+).*?([章节幕回折]))([#{SEPS}\s】]*)(.*)$/

  TITLE_RE_3 = /^(\d+)([#{SEPS}\s]*)(.*)$/
  TITLE_RE_4 = /^楔\s+子(\s+)(.+)$/

  def tl_title(title : String)
    if match = LABEL_RE_1.match(title) || TITLE_RE_1.match(title) || TITLE_RE_2.match(title)
      _, pre_zh, num, lbl, pad, title = match
      pre_cv = "#{tl_label(lbl)} #{to_integer(num)}"
      {pre_zh, pre_cv, pad, title}
    elsif match = TITLE_RE_3.match(title)
      _, num, pad, title = match
      {num, num, pad, title}
    elsif match = TITLE_RE_4.match(title)
      _, pad, title = match
      {"楔子", "Phần đệm", pad, title}
    else
      {"", "", "", title}
    end
  end

  def tl_label(label = "")
    case label
    when "章" then "Chương"
    when "卷" then "Quyển"
    when "集" then "Tập"
    when "节" then "Tiết"
    when "幕" then "Màn"
    when "回" then "Hồi"
    when "折" then "Chiết"
    else          "#"
    end
  end
end

# puts CV::MtUtil.normalize("０")
# puts CV::MtUtil.normalize('０')

# puts CV::MtUtil.to_integer("1245")
# puts CV::MtUtil.to_integer("四")
