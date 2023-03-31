require "./_rule_base"

module M2::MtRule
  def nn_to_np(data : MtData, node : MtNode, idx : Int32)
    data.add_node!(NP_Node.new(node), idx: idx)
  end

  add_rule "NN", ->nn_to_np(MtData, MtNode, Int32)
  add_rule "NT", ->nn_to_np(MtData, MtNode, Int32)
end
