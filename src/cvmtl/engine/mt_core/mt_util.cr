require "../../../_util/char_util"

module MT::MtUtil
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
      when '兆', '亿', '万', '千', '百', '十'
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
  end

  # :ditto:
  def to_integer(char : Char) : Int32 | Int64
    CharUtil::HANNUM_VALUE[char]? || char.to_i? || 0
  end

  NUMS = "零〇一二两三四五六七八九十百千"
  SEPS = ".，,、：:"

  LABEL_RE_1 = /^(【?第?([#{NUMS}]+|\d+)([集卷季])】?)([#{SEPS}\s]*)(.*)$/

  TITLE_RE_1 = /^(第.*?([#{NUMS}]+|\d+).*?([章节幕回折]))(.*?\d+\.\s)(.+)/
  TITLE_RE_2 = /^(.*?([#{NUMS}]+|\d+).*?([章节幕回折]))([#{SEPS}\s】]*)(.*)$/

  TITLE_RE_3 = /^(\d+)([#{SEPS}\s]*)(.*)$/
  TITLE_RE_4 = /^楔\s+子(\s+)(.+)$/

  MAP_LBL = {
    "季" => "Mùa",
    "章" => "Chương",
    "卷" => "Quyển",
    "集" => "Tập",
    "节" => "Tiết",
    "幕" => "Màn",
    "回" => "Hồi",
    "折" => "Chiết",
  }

  def tl_title(title : String)
    if match = LABEL_RE_1.match(title) || TITLE_RE_1.match(title) || TITLE_RE_2.match(title)
      _, pre_zh, num, lbl, pad, title = match
      pre_cv = "#{MAP_LBL[lbl]? || "#"} #{to_integer(num)}"
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
end
