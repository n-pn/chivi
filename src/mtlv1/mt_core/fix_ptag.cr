require "./fix_ptag/*"

module CV::MTL
  extend self

  def fix_ptag!(tail : BaseNode) : Nil
    while tail = tail.prev?
      next unless tail.is_a?(BaseTerm)

      case tail
      when .polysemy?
        tail = fix_polysemy!(tail)
      when .uniqword?
        tail = fix_uniqword!(tail)
      when .bond_word?
        tail = fix_bond_word!(tail)
      else
        tail = fix_baseterm!(tail)
      end
    end
  end

  def fix_polysemy!(node : BaseTerm)
    fixer = FixPolysemy.new(node)
    fixer = fixer.guess_by_succ
    fixer = fixer.guess_by_prev
    fixer.resolve!
  end

  def fix_uniqword!(node : BaseTerm)
    case node.tag
    when .qttemp? then fix_qttemp!(node)
    when .vauxil? then fix_vauxil!(node)
    when .vcompl? then fix_vcompl!(node)
    else
      node
    end
  end

  def fix_baseterm!(node : BaseTerm)
    case node.tag
    when .pt_dep? then fix_pt_dep!(node)
    when .pt_dev? then fix_pt_dev!(node)
    when .pt_der? then fix_pt_der!(node)
    when .pt_der? then fix_pt_der!(node)
    else               node
    end
  end

  def fix_bond_word!(node : BaseTerm, prev = node.prev, succ = node.succ) : BaseTerm
    # FIXME: check for exceptions

    case prev.tag
    when .noun_words?
      node.set_tag!(MtlTag::BondNoun)
    when .adjt_words?
      case succ.tag
      when .adjt_words?
        node.set_tag!(MtlTag::BondAdjt)
      else
        node.set_tag!(MtlTag::BondDmod)
      end
    when .verb_words?
      node.set_tag!(MtlTag::BondVerb)
    else
      node
    end
  end
end
