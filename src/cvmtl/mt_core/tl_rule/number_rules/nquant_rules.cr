require "../../mt_util"

module CV::TlRule
  def fold_year!(prev : MtNode, node : MtNode, appro : Int32 = 0)
    node.val = "năm"

    if (number = node.succ?) && (quanti = number.succ?)
      if number.numbers? && quanti.key == "月"
        month = fold_month!(number, quanti, -1)
      end
    end

    if month || exact_year?(node, appro)
      prev = fold_swap!(prev, node, PosTag::Time, dic: 2)
      return month ? fold_swap!(prev, month, prev.tag, dic: 2) : prev
    end

    fold!(prev, node, PosTag::Qttime, dic: 2)
  end

  def exact_year?(node : MtNode, appro : Int32 = 0) : Bool
    return appro < 0 if appro != 0

    case node.tag
    when .number? then false
    when .ndigit? then node.to_int?.try(&.> 9) || false
    when .nhanzi?
      return false if node.key.size == 1
      node.key !~ /[百千万亿兆]/
    else
      false
    end
  end

  def fold_month!(prev : MtNode, node : MtNode, appro : Int32 = 0)
    node.val = "tháng"
    date = fold_day?(node.succ?)

    if date || appro == -1
      prev = fold_swap!(prev, node, PosTag::Time, dic: 2)
      return date ? fold_swap!(prev, date, prev.tag, dic: 2) : prev
    end

    if appro == 0 && prev.to_int?.try(&.< 13)
      # TODO: check more cases
      return fold_swap!(prev, node, PosTag::Time, dic: 2)
    end

    fold!(prev, node, PosTag::Qttime, dic: 2)
  end

  def fold_day?(num : MtNode?) : MtNode?
    return unless num && (day = num.succ?)
    return unless num.numbers? && day.key == "日" || day.key == "号"

    case day.key
    when "日" then day.val = "ngày"
    when "号" then day.val = num.to_int?.try(&.< 11) ? "mồng" : "ngày"
    else          return
    end

    fold_swap!(num, day, PosTag::Time, dic: 3)
  end

  def fold_hour!(node : MtNode, succ : MtNode, appro : Int32 = 0)
    fold!(node, succ, PosTag::Qttime, dic: 2)
  end

  def fold_minute!(node : MtNode, succ : MtNode, appro : Int32 = 0)
    fold!(node, succ, PosTag::Qttime, dic: 2)
  end

  def clean_个!(node : MtNode) : MtNode
    if body = node.body?
      deep_clean_个!(body)
    elsif node.key.ends_with?('个')
      if node.key.size > 1 || node.prev?(&.pro_dems?)
        node.val = node.val.sub("cái", "").strip
      end
    end

    node
  end

  def deep_clean_个!(node : MtNode) : Nil
    while true
      return node.set!("") if node.key == "个"
      break unless node = node.succ?
    end
  end
end
