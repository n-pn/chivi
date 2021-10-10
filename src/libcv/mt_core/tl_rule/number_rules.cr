module CV::TlRule
  def fold_number!(node : MtNode) : MtNode
    node = meld_number!(node)
    return node unless succ = node.succ?

    node = fold_pre_quanti_appro!(node, succ)
    has_第 = node.key.starts_with?("第")

    if prev = node.prev?
      case prev.key
      when "第"
        has_第 = true
        node = node.fold_left!(prev, "thứ #{node.val}")
      when "约"
        node = node.fold_left!(prev, "chừng #{node.val}")
      end
    end

    return node unless succ = node.succ?

    if succ.pre_dui?
      if (succ_2 = succ.succ?) && succ_2.numbers?
        node.val = "#{node.val} đối #{succ_2.val}"
        node.dic = 6
        node.tag = PosTag::Aform
        return node.fold_many!(succ, succ_2)
      end

      node.heal!("đôi", PosTag::Quanti)
    else
      succ = heal_quanti!(succ)
      return node unless succ.quantis?
    end

    # merge number with quantifiers
    if !has_第
      node.tag = PosTag::Nquant
      node.fold!("#{node.val} #{succ.val}")
    elsif succ.succ?(&.nouns?)
      succ_2 = succ.succ
      node.dic = 7
      node.tag = PosTag::Nform
      node.val = "#{succ.val} #{succ_2.val} #{node.val}"
      return node.fold_many!(succ, succ_2)
    else
      node.tag = PosTag::Nquant
      node.fold!("#{succ.val} #{node.val}")
    end

    fold_suf_quanti_appro!(node)
  end

  def meld_number!(node : MtNode)
    while succ = node.succ?
      if succ.numhan? || succ.numlat?
        node.tag = PosTag::Number if node.tag != succ.tag
        node = node.fold!(succ)
        next
      end

      if node.numhan?
        break unless (succ_2 = succ.succ?) && succ_2.numhan?
        break unless succ.key == "点"

        node.val = "#{node.val} chấm #{succ_2.val}"
        node.fold_many!(succ, succ_2)
      elsif node.numlat?
        break unless (succ_2 = succ.succ?) && succ_2.numlat?

        case succ.tag
        when .pdeci? # case 1.2
          node.val = "#{node.val}.#{succ_2.val}"
          node.fold_many!(succ, succ_2)
          break
        when .pdash? # case 3-4
          node.tag = PosTag::Number
          node.val = "#{node.val}-#{succ_2.val}"
          node.fold_many!(succ, succ_2)
          break
        when .colon? # for 5:6 format
          node.tag = PosTag::Time
          node.val = "#{node.val}:#{succ_2.val}"
          node.fold_many!(succ, succ_2)

          # for 5:6:7 format
          if succ_2.succ? { |x| x.colon? && x.succ?(&.numlat?) }
            succ_3 = succ_2.succ
            succ_4 = succ_3.succ
            node.val = "#{node.val}:#{succ_2.val}:#{succ_4.val}"
            node.fold_many!(succ_3, succ_4)
          end

          break
        else
          break
        end
      else
        break
      end
    end

    # TODO: correct translate unit system
    node
  end
end
