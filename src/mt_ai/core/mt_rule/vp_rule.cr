class MT::AiCore
  def fix_vp_node!(vp_node : MtNode, vp_body : MtDefn | MtNode) : MtNode
    vp_node
  end

  def fix_vp_node!(vp_node : MtNode, vp_body : MtPair) : MtNode
    fix_vp_node!(vp_node, [vp_body.head, vp_body.tail])
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def fix_vp_node!(vp_node : MtNode, vp_body : Array(MtNode)) : MtNode
    if vp_body.last.zstr.in?("似的", "一样", "一般", "般")
      return fix_cmp_type_1!(vp_node, vp_body)
    end

    fix_vp_body!(vp_body) || vp_node
  end

  def fix_vp_body!(vp_body : Array(MtNode)) : MtNode?
    pos, max = 0, vp_body.size
    preps = [] of MtNode

    while pos < max
      node = vp_body.unsafe_fetch(pos)
      pos &+= 1

      case node.epos
      when .verb?, .adjt?
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

    return nil unless vv_node

    if vv_node.epos.vnv?
      vv_node = split_vnv!(vv_node, vv_node.body, vp_body)
      max = vp_body.size
    end

    while last = preps.last?
      break unless last.attr.prfx?
      ad_node = preps.pop

      fix_d_v_pair!(ad_node: ad_node, vv_node: vv_node)
      vv_node = init_pair_node(ad_node, vv_node, epos: vv_node.epos, attr: vv_node.attr, flip: ad_node.attr.at_t?)
    end

    vp_node = vv_node

    while pos < max
      node = vp_body.unsafe_fetch(pos)
      case node.epos
      when .is?(:AS)
        pos &+= 1
        # hide_as_node = vp_body[pos]?.try(&.epos.verb?) || false
        vp_node = init_vp_as_pair(vp_node, node)
      when .np?
        vp_node = init_vp_np_pair(vp_node, np_node: node, vv_node: vv_node)
        pos &+= 1
      when .vv?, .ip?, .vp?, .pp?, .advp?
        # TODO: handle join
        vp_node = init_vp_ip_pair(vp_node, ip_node: node, vv_node: vv_node)
        pos &+= 1
        break
      else
        break
      end
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

      case node.epos
      when .qp?
        vp_node = init_vp_qp_pair(vp_node, qp_node: node, vv_node: vv_node)
      else
        vp_node = init_pair_node(vp_node, node, epos: :VP, attr: :none, flip: false)
      end
    end

    vp_node
  end

  def fix_p_v_pair!(pp_node : MtNode, vv_node : MtNode) : Nil
    return unless p_node = pp_node.find_by_epos(:P)

    nn_node = pp_node.inner_tail
    unless PairDict.v_n_pair.fix_if_match!(p_node, nn_node)
      # TODO
    end

    PairDict.p_v_pair.fix_if_match!(p_node, vv_node)
    pp_node.attr |= :At_t if p_node.attr.at_t?
  end

  def fix_d_v_pair!(ad_node : MtNode, vv_node : MtNode) : Nil
    vv_head = vv_node.inner_head

    unless PairDict.d_v_pair.fix_if_match!(ad_node, vv_node) || PairDict.d_v_pair.fix_if_match!(ad_node, vv_head)
      case ad_node.zstr
      when "好"
        ad_node.body = vv_head.epos.adjt? || vv_head.attr.vmod? ? "thật" : "dễ"
      when "多"
        if vv_node.epos.adjt?
          ad_node.body = "bao"
          ad_node.attr = :at_h
        else
          ad_node.body = "nhiều"
          ad_node.attr = :at_t
        end
      end
    end
  end

  private def init_vp_as_pair(vp_node, as_node, hide_as_node : Bool = false)
    init_pair_node(vp_node, as_node, epos: :VAS, attr: :none) do
      as_node.attr = :hide unless as_node.zstr == "过"
      MtPair.new(vp_node, as_node, flip: false)
    end
  end

  # private def fix_as_node!(as_node)
  #   case as_node.zstr
  #   when "着"
  #     as_node.body = "đang"
  #     as_node.attr = :none
  #     true
  #   when "了"
  #     as_node.body = "đã"
  #     as_node.attr = :none
  #     true
  #   when "过"
  #     as_node.body = "từng"
  #     as_node.attr = :none
  #     true
  #   else
  #     false
  #   end
  # end

  private def init_vp_np_pair(vp_node, np_node, vv_node)
    init_pair_node(vp_node, np_node, epos: :VP, attr: :none) do
      # TODO: extract nn_node from np_node

      unless PairDict.v_n_pair.fix_if_match!(vv_node, np_node)
        case vv_node.zstr
        when "想"
          vv_node.body = "nhớ"
        when "不想"
          vv_node.body = "không nhớ"
        when "会"
          vv_node.body = "biết"
        when "不会"
          vv_node.body = "không biết"
        end
      end

      MtPair.new(vp_node, np_node, flip: false)
    end
  end

  private def init_vp_ip_pair(vp_node, ip_node, vv_node)
    init_pair_node(vp_node, ip_node, epos: :VP, attr: :none) do
      ip_head = ip_node.inner_head

      unless PairDict.v_v_pair.fix_if_match!(vv_node, ip_node) || PairDict.v_v_pair.fix_if_match!(vv_node, ip_head)
        case vv_node.zstr
        when "想"
          vv_node.body = "muốn"
        when "不想"
          vv_node.body = "không muốn"
        when "会"
          vv_node.body = ip_is_skill?(ip_node) ? "biết" : "sẽ"
        when "不会"
          vv_node.body = ip_is_skill?(ip_node) ? "không biết" : "sẽ không"
        end
      end

      MtPair.new(vp_node, ip_node, flip: false)
    end
  end

  private def ip_is_skill?(ip_node, ip_body = ip_node.body)
    return false unless ip_node.epos.vp?
    # TODO: check for combined case

    return false unless ip_body.is_a?(MtPair)
    ip_body.head.epos.verb? && ip_body.tail.epos.verb?
  end

  private def init_vp_qp_pair(vp_node, qp_node, vv_node)
    init_pair_node(vp_node, qp_node, epos: :VP, attr: :none) do
      unless (m_node = qp_node.find_by_epos(:M)) && PairDict.v_c_pair.fix_if_match!(vv_node, m_node)
        case vv_node.zstr
        when "会"
          vv_node.body = "sẽ"
        when "不会"
          vv_node.body = "sẽ không"
        end
      end

      MtPair.new(vp_node, qp_node, flip: false)
    end
  end
end
