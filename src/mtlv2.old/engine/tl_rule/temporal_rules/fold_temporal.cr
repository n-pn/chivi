module MtlV2::TlRule
  def fold_temporal!(node : BaseNode, succ = node.succ?) : BaseNode
    return node if !succ || succ.ends?

    if succ.adj_hao? && node.key.in?("早上", "下午", "凌晨", "早晨", "中午", "晚上")
      return fold!(node, succ.set!("chào"), PosTag::None, dic: 8, flip: true)
    end

    case succ
    when .numbers? then fold_number!(succ, prev: node)
    when .v_shi?   then node
    when .v_you?   then node
    when .verbal?
      return node if succ.adverbial?
      fold_verbs!(succ, adverb: node)
    else
      fold_nouns!(node)
    end
  end

  def fold_time_prev!(node : BaseNode, prev : BaseNode?) : BaseNode
    return fold_time_after!(node) unless prev

    flip = true

    case prev.key
    when "早上" then prev.val = "sáng"
    when "早晨" then prev.val = "sáng"
    when "中午" then prev.val = "trưa"
    when "下午" then prev.val = "chiều"
    when "晚上" then prev.val = "tối"
    when "半夜" then prev.val = "đêm"
    when "凌晨" then flip = false
    end

    time = fold!(prev, node, PosTag::Ntime, dic: 2, flip: flip)
    fold_time_after!(time)
  end

  def fold_time_after!(time : BaseNode, succ = time.succ?)
    return time if !succ || succ.ends?

    case succ.key
    when "多"  then succ.val = "hơn"
    when "前后" then succ.val = "tầm"
    when "左右" then succ.val = "khoảng"
    else
      return fold_noun_other!(time)
    end

    time = fold!(time, succ, time.tag, dic: 2, flip: true)
    fold_noun_other!(time)
  end

  def fold_number_hour!(node : BaseNode, succ : BaseNode) : BaseNode
    node = fold!(node, succ.set!("giờ"), PosTag::Ntime, dic: 1)

    return node unless (succ = node.succ?)

    case succ.key
    when "半"
      return fold!(node, succ.set!("rưỡi"), PosTag::Ntime, dic: 1)
    when "前后"
      return fold!(node, succ.set!("tầm"), PosTag::Ntime, dic: 1, flip: true)
    end

    return node unless minute = read_minute_quanti?(succ)
    node = fold!(node, minute.set!("phút"), PosTag::Ntime, dic: 1)

    return node unless second = read_second_quanti?(minute.succ?)
    fold!(node, second.set!("giây"), PosTag::Ntime, dic: 1)
  end

  def read_minute_quanti?(node : BaseNode?)
    return unless node && (succ = node.succ?) && node.numbers?
    succ.key == "分" || succ.key == "分钟" ? succ : nil
  end

  def read_second_quanti?(node : BaseNode?)
    return unless node && (succ = node.succ?) && node.numbers?
    succ.key == "秒" || succ.key == "秒钟" ? succ : nil
  end

  def fold_number_minute!(node : BaseNode, succ : BaseNode, is_time = false) : BaseNode
    if (succ_2 = succ.succ?) && succ_2.key == "半"
      succ.val = "phút"
      return fold!(node, succ_2.set!("rưỡi"), PosTag::Ntime, dic: 1)
    end

    return node unless is_time || (second = read_second_quanti?(succ.succ?))

    node = fold!(node, succ.set!("phút"), PosTag::Ntime, dic: 1)
    return node unless second

    fold!(node, second.set!("giây"), PosTag::Ntime, dic: 1)
  end
end