module CV::TlRule
  # modes:
  # 0 : to be determined
  # 1 : exact date
  # 2 : time span

  def fold_number_as_temporal(num : MtNode, qti : MtNode, prev : MtNode? = nil) : MtNode?
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

  def map_temporal_mode(prev : MtNode?)
    return 1 if !prev || prev.puncts? || prev.none?
    return prev.pre_zai? ? 1 : 2 if prev.prepos?

    if prev.verbal?
      return 2 if prev.verb_object? || prev.key.in?("近", "约", "小于")
      return 1 if prev.flag.has_pre_zai?
    end

    0
  end

  def fold_year!(year_num : MtNode, year : MtNode, mode : Int32 = 0)
    year.val = "năm"

    if (num = year.succ?) && num.numbers? && (mo = num.succ?) && mo.key == "月"
      month = fold_month!(num, mo, 1)
    end

    unless month || mode == 1 || (mode == 0 && exact_year?(year))
      return fold!(year_num, year, PosTag::Qttime, dic: 2)
    end

    year = fold!(year_num, year, PosTag::Temporal, dic: 2, flip: true)
    month ? fold!(year, month, year.tag, dic: 3, flip: true) : year
  end

  private def exact_year?(year : MtNode) : Bool
    year.tag.ndigit? || year.key !~ /[百千万亿兆]/
  end

  def fold_month!(mo_num : MtNode, mo : MtNode, mode : Int32 = 0)
    # puts [mo_num, mo, mode, "fold_month"]

    mo.val = "tháng"

    if (num = mo.succ?) && num.numbers? && (date = num.succ?) && date.key.in?("日", "初", "号")
      day = fold_day!(num, date, 1)
    end

    unless day || mode == 1 || (mode == 0 && mo_num.to_int?.try(&.< 13))
      return fold!(mo_num, mo, PosTag::Qttime, dic: 2)
    end

    month = fold!(mo_num, mo, PosTag::Temporal, dic: 2, flip: true)
    day ? fold!(month, day, month.tag, dic: 3, flip: true) : month
  end

  def fold_day!(num : MtNode, qti : MtNode, mode : Int32 = 0) : MtNode
    # puts [num, qti, mode, "fold_day"]

    case qti.key
    when "日" then qti.val = "ngày"
    when "初" then qti.val = "mồng"
    when "号" then qti.val = num.to_int?.try(&.< 11) ? "mồng" : "ngày"
    end

    fold!(num, qti, PosTag::Temporal, dic: 3, flip: mode == 1)
  end

  def fold_hour!(node : MtNode, succ : MtNode, appro : Int32 = 0)
    fold!(node, succ, PosTag::Qttime, dic: 2)
  end

  def fold_minute!(node : MtNode, succ : MtNode, appro : Int32 = 0)
    fold!(node, succ, PosTag::Qttime, dic: 3)
  end
end
