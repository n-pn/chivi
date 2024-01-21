class MT::AiCore
  def fix_vp_node!(vp_node : MtNode, vp_body : MtDefn | MtNode) : MtNode
    vp_node
  end

  def fix_vp_node!(vp_node : MtNode, vp_body : MtPair) : MtNode
    fix_vp_node!(vp_node, [vp_body.head, vp_body.tail])
  end

  def fix_vp_node!(vp_node : MtNode, vp_body : Array(MtNode)) : MtNode
    if vp_body.last.zstr == "了"
      vp_body.last.body = "rồi"
      vp_body.last.epos = :SP
    end

    pos, max = 0, vp_body.size
    preps = [] of MtNode

    while pos < max
      node = vp_body.unsafe_fetch(pos)

      pos &+= 1

      case node.epos
      when .vv?
        vv_node = node
        break
      when .pu?
        if last = preps.last?
          preps[-1] = init_pair_node(last, node, epos: :ADVP, attr: :at_h, flip: false)
        else
          preps << node
        end
      else
        preps << node
      end
    end

    return vp_node unless vv_node
    vp_node = vv_node

    while pos < max
      node = vp_body.unsafe_fetch(pos)
      case node.epos
      when .is?(:AS)
        vp_node = init_pair_node(vp_node, node, epos: :VAS, attr: vv_node.attr, flip: false)
      when .np?
        vp_node = init_vp_np_pair(vp_node, np_node: node, vv_node: vv_node)
      when .vv?, .ip?, .vp?, .pp?
        # TODO: handle join
        vp_node = init_pair_node(vp_node, node, epos: :VP, attr: :none, flip: false)
      else
        break
      end

      pos &+= 1
    end

    preps.reverse_each do |prep|
      case prep.epos
      when .pp?
        fix_p_v_pair!(pp_node: prep, vv_node: vv_node)
      else
        fix_d_v_pair!(ad_node: prep, vv_node: vv_node)
      end

      vp_node = init_pair_node(prep, vp_node, epos: :VP, attr: :none, flip: prep.attr.at_t?)
    end

    while pos < max
      node = vp_body.unsafe_fetch(pos)
      pos &+= 1
      # TODO: handle qp
      vp_node = init_pair_node(vp_node, node, epos: :VP, attr: :none, flip: false)
    end

    vp_node
  end

  def fix_p_v_pair!(pp_node : MtNode, vv_node : MtNode) : Nil
    return unless p_node = pp_node.find_by_epos(:P)
    PairDict.p_v_pair.fix_if_match!(p_node, vv_node)
    pp_node.attr |= :At_t if p_node.attr.at_t?
  end

  def fix_d_v_pair!(ad_node : MtNode, vv_node : MtNode) : Nil
    case ad_node.zstr
    when "好"
      ad_node.body = vv_node.epos.is?(:VA) ? "thật" : "dễ"
    when "多"
      if vv_node.epos.is?(:VA)
        ad_node.body = "bao"
        ad_node.attr = :at_h
      else
        ad_node.body = "nhiều"
        ad_node.attr = :at_t
      end
    end

    PairDict.d_v_pair.fix_if_match!(ad_node, vv_node)
  end

  private def init_vp_np_pair(vp_node, np_node, vv_node)
    init_pair_node(vp_node, np_node, epos: :VP, attr: :none) do
      # TODO: extract nn_node from np_node

      PairDict.v_n_pair.fix_if_match!(vv_node, np_node)
      MtPair.new(vp_node, np_node, flip: false)
    end
  end
end
