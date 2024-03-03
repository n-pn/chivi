require "../../../_util/tran_util/tl_number"

module M1::MtUtil
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

  HAN_VAL = {
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

  # :ditto:
  def to_integer(char : Char) : Int32 | Int64
    HAN_VAL.fetch(char) { char.to_i? || 0 }
  end

  NUMS = "零〇一二两三四五六七八九十百千"
  DIVS = "章节幕回折"

  LBLS = {
    "季" => "Mùa",
    "章" => "Chương",
    "卷" => "Quyển",
    "集" => "Tập",
    "节" => "Tiết",
    "幕" => "Màn",
    "回" => "Hồi",
    "折" => "Chiết",
  }

  LABEL_RE_1 = /^(\p{Ps}?第?([#{NUMS}]+|[０-９]+|\d+)([集卷季])\p{Pe}?)([\p{P}\s　]*)(.*)$/

  TITLE_RE_1 = /^(第[　\s]*([#{NUMS}]+|[０-９]+|\d+)[　\s]*([章节幕回折]))([\p{P}\s　]*)(.+)/
  TITLE_RE_2 = /^(\p{Ps}?([#{NUMS}]+|[０-９]+|\d+)\p{Pe}?([章节幕回折]))([\p{P}\s　]*)(.*)$/

  TITLE_RE_3 = /^(\d+|[０-９]+)([\p{P}\s　]*)(.*)$/
  TITLE_RE_4 = /^(楔\s*子)(\s+|　+)(.+)$/

  def tl_title(title : String)
    if match = LABEL_RE_1.match(title) || TITLE_RE_1.match(title) || TITLE_RE_2.match(title)
      _, idx_zh, num, lbl, pad, title = match
      idx_cv = String.build do |io|
        io << LBLS.fetch(lbl, "#") << ' '
        io << TlNumber.translate(num, scale: 1)
      end

      {idx_zh, idx_cv, pad, title}
    elsif match = TITLE_RE_3.match(title)
      _, num, pad, title = match
      {num, num, pad, title}
    elsif match = TITLE_RE_4.match(title)
      _, idx, pad, title = match
      {idx, "Phần đệm", pad, title}
    else
      {"", "", "", title}
    end
  end
end

# puts M1::MtUtil.normalize("０")
# puts M1::MtUtil.normalize('０')

# puts M1::MtUtil.to_integer("1245")
# puts M1::MtUtil.tl_title("第1章 归序者")
# puts M1::MtUtil.tl_title("第１章　业余的悍匪")
# puts M1::MtUtil.tl_title("第１章　业余的悍匪")
