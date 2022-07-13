module QtranUtil
  extend self

  def capitalize(inp : String)
    res = String::Builder.new(inp.size)
    cap = true

    inp.each_char do |char|
      if cap && char.alphanumeric?
        res << char.upcase
        cap = false
      else
        res << char
      end
    end

    res.to_s
  end

  NUMS = "零〇一二两三四五六七八九十百千"
  SEPS = ".，,、：:"

  LABEL_RE_1 = /^(【?第?([#{NUMS}]+|\d+)([集卷季])】?)([#{SEPS}\s]*)(.*)$/

  TITLE_RE_1 = /^(第.*?([#{NUMS}]+|\d+).*?([章节幕回折]))(.*?\d+\.\s)(.+)/
  TITLE_RE_2 = /^(.*?([#{NUMS}]+|\d+).*?([章节幕回折]))([#{SEPS}\s】]*)(.*)$/

  TITLE_RE_3 = /^(\d+)([#{SEPS}\s]*)(.*)$/
  TITLE_RE_4 = /^楔\s+子(\s+)(.+)$/

  def tl_ch_title(title : String)
    if match = LABEL_RE_1.match(title) || TITLE_RE_1.match(title) || TITLE_RE_2.match(title)
      _, pre_zh, num, lbl, pad, title = match
      pre_cv = "#{tl_marker(lbl)} #{to_integer(num)}"
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

  def tl_marker(marker = "")
    case marker
    when "季" then "Mùa"
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

  def read_tsv(file : String) : Hash(String, Array(String))
    output = {} of String => Array(String)
    return output unless File.exists?(file)

    File.read_lines(file).each_with_object(output) do |line, hash|
      next unless (char = line[0]?) && char != '#'
      vals = line.split('\t')
      key = vals.shift
      hash[key] = vals
    end
  end

  HAN_INT = {
    '零' => 0,
    '〇' => 0,
    '一' => 1,
    '两' => 2,
    '二' => 2,
    '三' => 3,
    '四' => 4,
    '五' => 5,
    '六' => 6,
    '七' => 7,
    '八' => 8,
    '九' => 9,
    '十' => 10,
    '百' => 100,
    '千' => 1000,
    '万' => 10_000,
    '亿' => 100_000_000,
    '兆' => 1_000_000_000_000,
  }

  def to_int(inp : String)
    res = 0_i64
    mod = 1_i64
    acc = 0_i64

    inp.chars.reverse_each do |char|
      int = HAN_INT[char]? || 0

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
end
