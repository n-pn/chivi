module MT::TlRule
  # modes:
  # 0 : to be determined
  # 1 : exact date
  # 2 : time span

  def fold_number_as_temporal(num : BaseNode, qti : BaseNode, prev : BaseNode? = nil) : BaseNode?
    mode = prev ? (prev.temporal? ? 1 : 2) : map_temporal_mode(num.prev?)

    # puts [num, qti, prev, mode, "fold_number_as_temporal"]

    case qti.key
    when "年" then fold_year!(num, qti, mode)
    when "月" then fold_month!(num, qti, mode)
    when "点" then fold_hour!(num, qti, mode)
    when "时" then fold_hour!(num, qti, mode)
    when "分" then fold_minute!(num, qti, mode)
    when "日", "初", "号"
      fold_day!(num, qti, mode) if mode == 1
    else
      nil
    end
  end

  def map_temporal_mode(prev : BaseNode?)
    return 1 if !prev || prev.punctuations? || prev.none?
    return prev.pre_zai? ? 1 : 2 if prev.prepos?
    return prev.flag.has_pre_zai? ? 1 : 2 if prev.verbal?
    return 1 if prev.pro_per?

    0
  end

  def fold_year!(year_num : BaseNode, year : BaseNode, mode : Int32 = 0)
    year.val = "năm"

    if (num = year.succ?) && num.numbers? && (mo = num.succ?) && mo.key == "月"
      month = fold_month!(num, mo, 1)
    end

    unless month || mode == 1 || (mode == 0)
      return fold!(year_num, year, PosTag::Nqtime, dic: 2)
    end

    year = fold!(year_num, year, PosTag::Texpr, dic: 2, flip: true)
    month ? fold!(year, month, year.tag, dic: 3, flip: true) : year
  end

  private def exact_year?(year : BaseNode) : Bool
    year.tag.ndigits? || year.key !~ /[两百千万亿兆]/
  end

  def fold_month!(mo_num : BaseNode, mo : BaseNode, mode : Int32 = 0)
    # puts [mo_num, mo, mode, "fold_month"]

    mo.val = "tháng"

    if (num = mo.succ?) && num.numbers? && (date = num.succ?) && date.key.in?("日", "初", "号")
      day = fold_day!(num, date, 1)
    end

    unless day || mode == 1 || (mode == 0 && mo_num.to_int?.try(&.< 13))
      return fold!(mo_num, mo, PosTag::Nqtime, dic: 2)
    end

    month = fold!(mo_num, mo, PosTag::Texpr, dic: 2, flip: true)
    day ? fold!(month, day, month.tag, dic: 3, flip: true) : month
  end

  def fold_day!(num : BaseNode, qti : BaseNode, mode : Int32 = 0) : BaseNode
    # puts [num, qti, mode, "fold_day"]

    case qti.key
    when "日" then qti.val = "ngày"
    when "初" then qti.val = "mồng"
    when "号" then qti.val = num.to_int?.try(&.< 11) ? "mồng" : "ngày"
    end

    fold!(num, qti, PosTag::Texpr, dic: 3, flip: mode == 1)
  end

  def fold_hour!(node : BaseNode, succ : BaseNode, appro : Int32 = 0)
    fold!(node, succ, PosTag::Nqtime, dic: 2)
  end

  def fold_minute!(node : BaseNode, succ : BaseNode, appro : Int32 = 0)
    fold!(node, succ, PosTag::Nqtime, dic: 3)
  end
end
