module MT::TlRule
  def fold_timeword!(node : MtNode, succ = node.succ?) : MtNode
    return node unless succ

    case node.key
    when "早上", "下午", "凌晨", "早晨", "中午", "晚上"
      case succ.tag
      when .nhanzis?, .ndigits?
        fold_number!(succ, prev: node)
      when .wd_hao?
        fold!(node, succ.set!("chào"), PosTag::Vform, flip: true)
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
      fold!(prev.set!("sáng"), node, PosTag::Texpr, flip: true)
    when "中午"
      fold!(prev.set!("trưa"), node, PosTag::Texpr, flip: true)
    when "下午"
      fold!(prev.set!("chiều"), node, PosTag::Texpr, flip: true)
    when "晚上"
      fold!(prev.set!("tối"), node, PosTag::Texpr, flip: true)
    when "半夜"
      fold!(prev.set!("đêm"), node, PosTag::Texpr, flip: true)
    when "凌晨"
      fold!(prev, node, PosTag::Texpr)
    else node
    end
  end

  def fold_time_appro!(node : MtNode)
    return node unless (succ = node.succ?) && succ.is_a?(MonoNode)
    case succ.key
    when "前后"
      fold!(node, succ.set!("tầm"), PosTag::Texpr, flip: true)
    when "左右"
      fold!(node, succ.set!("khoảng"), PosTag::Texpr, flip: true)
    when "多"
      fold!(node, succ.set!("hơn"), PosTag::Texpr, flip: true)
    else
      node
    end
  end

  def fold_number_hour!(node : MtNode, succ : MtNode) : MtNode
    node = fold!(node, succ.set!("giờ"), tag: PosTag::Texpr)

    return node unless (succ = node.succ?) && succ.is_a?(MonoNode)

    case succ.key
    when "半"
      return fold!(node, succ.set!("rưỡi"), PosTag::Texpr)
    when "前后"
      return fold!(node, succ.set!("tầm"), PosTag::Texpr, flip: true)
    end

    return node unless minute = read_minute_quanti?(succ)
    node = fold!(node, minute.set!("phút"), PosTag::Texpr)

    return node unless second = read_second_quanti?(minute.succ?)
    fold!(node, second.set!("giây"), PosTag::Texpr)
  end

  def read_minute_quanti?(node : MtNode?) : MonoNode?
    return unless node && node.numbers?
    return unless (succ = node.succ?) && succ.is_a?(MonoNode)

    succ.key == "分" || succ.key == "分钟" ? succ : nil
  end

  def read_second_quanti?(node : MtNode?) : MonoNode?
    return unless node && node.numbers?
    return unless (succ = node.succ?) && succ.is_a?(MonoNode)

    succ.key == "秒" || succ.key == "秒钟" ? succ : nil
  end

  def fold_number_minute!(node : MtNode, succ : MtNode, is_time = false) : MtNode
    if (succ_2 = succ.succ?) && succ_2.key == "半"
      succ.val = "phút"
      return fold!(node, succ_2.set!("rưỡi"), PosTag::Texpr)
    end

    return node unless is_time || (second = read_second_quanti?(succ.succ?))

    node = fold!(node, succ.set!("phút"), PosTag::Texpr)
    return node unless second

    fold!(node, second.set!("giây"), PosTag::Texpr)
  end
end
