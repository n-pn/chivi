module MT::Rules
  def fix_mixedpos!(node : MonoNode)
    case node
    when .polysemy?   then fix_polysemy!(node)
    when .uniqword?   then fix_uniqword!(node)
    when .maybe_auxi? then fix_vauxil!(node)
    else                   node
    end
  end

  def fix_mixedpos!(node : MtNode)
    Log.warn { "this should not happen!" }
    node
  end
end
