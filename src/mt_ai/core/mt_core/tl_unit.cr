require "../../util/qt_number"

module MT::TlUnit
  extend self

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
    qnode = HashDict.nqnt_vi.any?(qzstr) || HashDict.essence.any?(qzstr)

    qvstr = qnode.try(&.vstr) || qzstr
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

  def self.translate_cd(input : String)
    translate_mq(input).try { |x| return x }

    head, mid, tail = input.partition("分之")
    vstr = tail.empty ? "" : translate(tail)

    return vstr if head.empty?
    return "#{vstr} phần" unless mid.empty?

    sufx = PERC_HEAD.put_if_absent(head) { QtNumber.translate(head) }
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

    real_vstr = QtNumber.translate(int_part)
    return real_vstr if mid_part.empty?

    if frac_part.empty?
      sep_vstr = NORM_SEP[mid_part[0]]
      return "#{real_vstr}#{sep_vstr}"
    end

    sep_vstr = DECI_SEP[mid_part[0]]
    frac_vstr = QtNumber.translate(frac_part)
    "#{real_vstr}#{sep_vstr}#{frac_vstr}"
  rescue ex
    Log.error(exception: ex) { input }
    input
  end

  ###
end
