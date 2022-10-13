require "../../mt_util"

module MT::TlRule
  def fold_year!(prev : BaseNode, node : BaseNode, appro : Int32 = 0)
    node.val = "năm"

    if (number = node.succ?) && (quanti = number.succ?)
      if number.numbers? && quanti.key == "月"
        month = fold_month!(number, quanti, -1)
      end
    end

    if month || exact_year?(node, appro)
      prev = fold!(prev, node, MapTag::Texpr, flip: true)
      return month ? fold!(prev, month, prev.tag, flip: true) : prev
    end

    fold!(prev, node, MapTag::Nqtime)
  end

  def exact_year?(node : BaseNode, appro : Int32 = 0) : Bool
    return appro < 0 if appro != 0

    case node.tag
    when .numeric? then false
    when .ndigits? then node.to_int?.try(&.> 9) || false
    when .nhanzis?
      return false if node.key.size == 1
      node.key !~ /[百千万亿兆]/
    else
      false
    end
  end

  def fold_month!(prev : BaseNode, node : BaseNode, appro : Int32 = 0)
    node.val = "tháng"
    date = fold_day?(node.succ?)

    if date || appro == -1
      prev = fold!(prev, node, MapTag::Texpr, flip: true)
      return date ? fold!(prev, date, prev.tag, flip: true) : prev
    end

    if appro == 0 && prev.to_int?.try(&.< 13)
      # TODO: check more cases
      return fold!(prev, node, MapTag::Texpr, flip: true)
    end

    fold!(prev, node, MapTag::Nqtime)
  end

  def fold_day?(num : BaseNode?) : BaseNode?
    return unless num && (day = num.succ?) && num.is_a?(MonoNode)
    return unless num.numbers? && day.key == "日" || day.key == "号"

    case day.key
    when "日" then day.val = "ngày"
    when "号" then day.val = num.to_int?.try(&.< 11) ? "mồng" : "ngày"
    else          return
    end

    fold!(num, day, MapTag::Texpr, flip: true)
  end

  def fold_hour!(node : BaseNode, succ : BaseNode, appro : Int32 = 0)
    fold!(node, succ, MapTag::Nqtime)
  end

  def fold_minute!(node : BaseNode, succ : BaseNode, appro : Int32 = 0)
    fold!(node, succ, MapTag::Nqtime)
  end

  def clean_个!(node : BaseNode) : BaseNode
    if body = node.body?
      deep_clean_个!(body)
    elsif node.key.ends_with?('个')
      if node.key.size > 1 || node.prev?(&.pro_dems?)
        node.val = node.val.sub("cái", "").strip
      end
    end

    node
  end

  def deep_clean_个!(node : BaseNode) : Nil
    loop do
      return node.set!("") if node.key == "个"
      break unless node = node.succ?
    end
  end
end
