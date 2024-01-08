require "./ai_node"
require "./ai_rule/*"

module MT::AiRule
  extend self

  # def split_dp(node : AiNode, &)
  #   case node
  #   when M1Node
  #     if node.zstr.size < 2 || !node.zstr[0].in?('这', '那')
  #       yield node
  #     else
  #       lhsn = M0Node.new(node.zstr[0].to_s, epos: :DT, _idx: node._idx)
  #       rhsn = M0Node.new(node.zstr[1..], epos: :QP, _idx: node._idx + 1)

  #       yield lhsn
  #       yield rhsn
  #     end
  #   when M2Node
  #     yield node.lhsn
  #     yield node.rhsn
  #   else
  #     yield node
  #   end
  # end

end
