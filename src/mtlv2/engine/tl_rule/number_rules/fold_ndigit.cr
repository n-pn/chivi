module MtlV2::TlRule
  # -ameba:disable Metrics/CyclomaticComplexity
  def fold_ndigit!(node : BaseNode, succ = node.succ, prev : BaseNode? = nil)
    return fold_ndigit_nhanzi!(node, succ) if succ.nhanzi?

    if time = fold_number_as_temporal(num: node, qti: succ, prev: prev)
      return time
    end

    return node unless (tail = succ.succ?) && tail.ndigit?

    case succ.tag
    when .pdeci? # case 1.2
      fold_ndigit_extra!(node, succ, tail, PosTag::Ndigit)
    when .pdash? # case 3-4
      fold_ndigit_extra!(node, succ, tail, PosTag::Number)
    when .colon? # for 5:6 format
      node = fold_ndigit_extra!(node, succ, tail, PosTag::Temporal)

      # for 5:6:7 format
      return node unless (succ = tail.succ?) && (tail = succ.succ?)
      return node unless succ.colon? && tail.ndigit?
      fold_ndigit_extra!(node, succ, tail, PosTag::Temporal)
    else
      node
    end
  end

  private def fold_ndigit_extra!(node : BaseNode, succ : BaseNode, tail : BaseNode, tag : PosTag)
    node.key = "#{node.key}#{succ.key}#{tail.key}"
    node.set!("#{node.val}#{succ.val}#{tail.val}", tag)
    node.tap(&.fix_succ!(tail.succ?))
  end

  def fold_ndigit_nhanzi!(node : BaseNode, succ : BaseNode) : BaseNode
    key_io = String::Builder.new(node.key)
    val_io = String::Builder.new(node.val)

    match_tag = PosTag::Nhanzi

    while succ.tag == match_tag
      key_io << succ.key
      val_io << " " << succ.val
      break unless succ = succ.succ?
      match_tag = PosTag::Ndigit
    end

    node.key = key_io.to_s
    node.val = val_io.to_s # TODO: correct unit system

    node.tag = PosTag::Number
    node.tap(&.fix_succ!(succ))
  end
end
