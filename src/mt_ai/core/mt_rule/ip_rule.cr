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
        sp_node ||= node
        fix_sp_in_ip!(sp_node: node, ip_node: ip_node, pu_node: pu_node)
      when .vp?
        fix_vp_in_ip!(vp_node: node, sp_node: sp_node)
      end
    end

    ip_node
  end

  private def fix_vp_in_ip!(vp_node, sp_node : MtNode? = nil)
    vp_tail = vp_node.inner_tail

    if vp_tail.zstr == "了"
      vp_tail.epos = :SP
      vp_tail.attr = :none
      vp_tail.body = "rồi"
    end
  end

  private def fix_sp_in_ip!(sp_node : MtNode, ip_node : MtNode, pu_node : MtNode?)
    case sp_node.zstr
    when "的话"
      # TODO: check for ADVP in the head
      case ip_body = ip_node.body
      when Array
        sp_node.body = "nếu như"
        ip_body.delete(sp_node)
        ip_body.unshift(sp_node)
      when MtPair
        ip_body.flip = true
        sp_node.body = "nếu như"
      else
        sp_node.body = "lời nói"
      end
    end
  end
end
