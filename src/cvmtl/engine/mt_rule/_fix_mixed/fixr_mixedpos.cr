module MT::Rules
  def fixr_mixedpos!(head : MonoNode, prev = head.prev, succ = head.succ)
    if succ.is_a?(MonoNode) && succ.mixedpos?
      succ = fixr_mixedpos!(head: succ, prev: head)
    end

    case head
    when .hao_word?             then fix_hao_word!(head, succ: succ)
    when .loc_shang?, .loc_xia? then fixr_shangxia!(head, succ: succ, prev: prev)
    when .polysemy?             then fixr_polysemy!(head, prev: prev, succ: succ)
    else                             head
    end
  end
end
