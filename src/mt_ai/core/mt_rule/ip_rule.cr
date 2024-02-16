class MT::AiCore
  def fix_ip_node!(ip_node : MtNode) : MtNode
    sp_node = nil
    pu_node = nil

    has_sbj = false
    has_obj = false

    ip_node.reverse_each do |node|
      case node.epos
      when .pu?
        pu_node ||= node
      when .sp?
        # TODO: fix sentent final particle
        sp_node ||= node
      when .vp?
        fix_vp_in_ip!(vp_node: node, sp_node: sp_node)
      end
    end

    # TODO: fix sp_node
    ip_node
  end

  private def fix_vp_in_ip!(vp_node, sp_node : MtNode? = nil)
    vp_tail = vp_node.inner_tail
    if vp_tail.zstr == "了"
      vp_tail.body = "rồi"
      vp_tail.attr = :none
    end
  end
end
