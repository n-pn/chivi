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
      else
        tail = fix_baseterm!(tail)
      end
    end
  end

  def fix_polysemy!(node : BaseTerm)
    fixer = FixPtag::FixPolysemy.new(node)
    fixer = fixer.guess_by_succ
    fixer = fixer.guess_by_prev
    fixer.resolve!
  end

  def fix_uniqword!(node : BaseTerm)
    node
  end

  def fix_baseterm!(node : BaseTerm)
    node
  end
end
