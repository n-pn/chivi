require "../../../_util/tran_util/tl_number"
require "../mt_data/trie_dict"

module MT::TlUnit
  def self.translate_od(zstr : String)
    case zstr[0]
    when '第' then "thứ #{translate(zstr[1..])}"
      # TODO: add more
    else translate(zstr)
    end
  end

  def self.translate_mq(zstr : String)
    return unless zstr.size == 3
    return unless zstr[0] == '一' && zstr[1] == zstr[2]

    qzstr = zstr[-1].to_s
    qdefn = TrieDict.nqnt_vi.any_defn?(qzstr) || TrieDict.regular.any_defn?(qzstr)

    qvstr = qdefn.try(&.vstr) || qzstr
    "từng #{qvstr} từng #{qvstr}"
  end

  PERC_HEAD = {
    "零" => "không",
    "〇" => "không",
    "一" => "một",
    "二" => "hai",
    "两" => "hai",
    "三" => "ba",
    "四" => "bốn",
    "五" => "năm",
    "六" => "sáu",
    "七" => "bảy",
    "八" => "tám",
    "九" => "chín",
    "几" => "vài",
    "十" => "mười",
    "百" => "trăm",
    "千" => "nghìn",
    "万" => "vạn",
    "亿" => "trăm triệu",
    "兆" => "nghìn tỉ",
  }

  def self.translate_cd(zstr : String)
    return "thứ #{translate(zstr[1..])}" if zstr[0] == '第'

    translate_mq(zstr).try { |x| return x }
    parts = zstr.split("分之", 2)

    return translate(zstr) unless tail = parts[1]?

    head = parts[0]
    vstr = translate(tail)
    sufx = PERC_HEAD.put_if_absent(head) { TlNumber.translate(head) }
    "#{vstr} phần #{sufx}"
  end

  DECI_SEP = {
    '点' => " chấm ",
    '．' => ".",
    '／' => "/",
  }

  NORM_SEP = {
    '点' => " điểm",
    '．' => ".",
    '／' => "/",
  }

  def self.translate(input : String)
    # just return the half-width version if all full width characters
    return CharUtil.to_halfwidth(input) if input.matches?(/^[／-～]+$/)

    # attempt to split string by delimiters
    int_part, mid_part, frac_part = input.partition(/[点．／]/)

    real_vstr = TlNumber.translate(int_part)
    return real_vstr if mid_part.empty?

    if frac_part.empty?
      sep_vstr = NORM_SEP[mid_part[0]]
      return "#{real_vstr}#{sep_vstr}"
    end

    sep_vstr = DECI_SEP[mid_part[0]]
    frac_vstr = TlNumber.translate(frac_part)

    "#{real_vstr}#{sep_vstr}#{frac_vstr}"
  rescue ex
    Log.error(exception: ex) { input }
    input
  end

  ###
end
