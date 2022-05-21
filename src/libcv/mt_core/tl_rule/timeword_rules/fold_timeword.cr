module CV::TlRule
  def fold_timeword!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    case node.key
    when "早上", "下午", "凌晨", "早晨", "中午", "晚上"
      case succ.tag
      when .nhanzi?, .ndigit?
        fold_number!(succ, prev: node)
      when .adj_hao?
        fold!(node, succ.set!("chào"), PosTag::VerbPhrase, dic: 8, flip: true)
      else
        node
      end
    else
      fold_nouns!(node)
    end
  end

  def fold_time_prev!(node : MtNode, prev : MtNode) : MtNode
    return node unless prev

    case prev.key
    when "早上", "早晨"
      fold!(prev.set!("sáng"), node, PosTag::Temporal, dic: 2, flip: true)
    when "中午"
      fold!(prev.set!("trưa"), node, PosTag::Temporal, dic: 2, flip: true)
    when "下午"
      fold!(prev.set!("chiều"), node, PosTag::Temporal, dic: 2, flip: true)
    when "晚上"
      fold!(prev.set!("tối"), node, PosTag::Temporal, dic: 2, flip: true)
    when "半夜"
      fold!(prev.set!("đêm"), node, PosTag::Temporal, dic: 2, flip: true)
    when "凌晨"
      fold!(prev, node, PosTag::Temporal, dic: 2)
    else node
    end
  end

  def fold_time_appro!(node : MtNode)
    return node unless succ = node.succ?
    case succ.key
    when "前后"
      fold!(node, succ.set!("tầm"), PosTag::Temporal, dic: 2, flip: true)
    when "左右"
      fold!(node, succ.set!("khoảng"), PosTag::Temporal, dic: 2, flip: true)
    when "多"
      fold!(node, succ.set!("hơn"), PosTag::Temporal, dic: 2, flip: true)
    else
      node
    end
  end

  def fold_number_hour!(node : MtNode, succ : MtNode) : MtNode
    node = fold!(node, succ.set!("giờ"), PosTag::Temporal, dic: 1)

    return node unless (succ = node.succ?)

    case succ.key
    when "半"
      return fold!(node, succ.set!("rưỡi"), PosTag::Temporal, dic: 1)
    when "前后"
      return fold!(node, succ.set!("tầm"), PosTag::Temporal, dic: 1, flip: true)
    end

    return node unless minute = read_minute_quanti?(succ)
    node = fold!(node, minute.set!("phút"), PosTag::Temporal, dic: 1)

    return node unless second = read_second_quanti?(minute.succ?)
    fold!(node, second.set!("giây"), PosTag::Temporal, dic: 1)
  end

  def read_minute_quanti?(node : MtNode?)
    return unless node && (succ = node.succ?) && node.numbers?
    succ.key == "分" || succ.key == "分钟" ? succ : nil
  end

  def read_second_quanti?(node : MtNode?)
    return unless node && (succ = node.succ?) && node.numbers?
    succ.key == "秒" || succ.key == "秒钟" ? succ : nil
  end

  def fold_number_minute!(node : MtNode, succ : MtNode, is_time = false) : MtNode
    if (succ_2 = succ.succ?) && succ_2.key == "半"
      succ.val = "phút"
      return fold!(node, succ_2.set!("rưỡi"), PosTag::Temporal, dic: 1)
    end

    return node unless is_time || (second = read_second_quanti?(succ.succ?))

    node = fold!(node, succ.set!("phút"), PosTag::Temporal, dic: 1)
    return node unless second

    fold!(node, second.set!("giây"), PosTag::Temporal, dic: 1)
  end
end
