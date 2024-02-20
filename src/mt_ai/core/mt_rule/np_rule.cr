# require "./ai_node"

class MT::AiCore
  def fix_np_node!(np_node : MtNode, np_body = np_node.body) : MtNode
    return np_node if np_body.is_a?(MtDefn) || np_body.is_a?(MtNode)
    np_body = [np_body.head, np_body.tail] if np_body.is_a?(MtPair)

    new_body = [] of MtNode
    _pos = np_body.size &- 1

    while _pos >= 0
      node = np_body.unsafe_fetch(_pos)
      _pos &-= 1

      if _pos >= 0 && node.epos.noun?
        node, _pos = init_nn_node(np_body, nn_node: node, _pos: _pos)
        node, _pos = init_np_node(np_body, np_node: node, _pos: _pos) if _pos >= 0
      end

      new_body.unshift(node)
    end

    if new_body.size > 1
      np_node.body = new_body
    elsif new_body.first.epos.np?
      np_node.attr |= new_body.first.attr
      np_node.body = new_body.first
    else
      np_node.body = new_body
      np_node.attr |= new_body.first.attr
    end

    np_node
  end

  # def fix_np_pair!(body : MtPair)
  #   head, tail = body.head, body.tail

  #   if !head.epos.noun?
  #     body.flip = !head.attr.at_h?
  #   elsif head.epos.nr?
  #     body.flip = flip_noun_pair?(head, tail)
  #   end

  #   body
  # end

  def init_nn_node(orig : Array(MtNode), nn_node : MtNode, _pos = orig.size - 2)
    attr = nn_node.attr.turn_off(MtAttr[Sufx, Undb])

    while _pos >= 0
      node = orig[_pos]

      case node.epos
      when .noun?
        nn_node = init_nn_nn_pair(head: node, tail: nn_node, attr: attr)
        _pos &-= 1
      when .adjp?
        # if current node is short modifier
        break unless node.attr.prfx?
        _pos &-= 1

        # combine the noun list for phrase translation
        flip = !node.attr.at_h?
        nn_node = init_pair_node(head: node, tail: nn_node, epos: :NN, attr: attr, flip: flip)
        # when .pu?
        #   # FIXME: check error in this part
        #   break if _pos == 0 || node.zstr[0] != '、'
        #   _pos &-= 1

        #   prev = orig[_pos]
        #   break unless prev.epos.noun?
        #   _pos &-= 1

        #   prev, _pos = init_nn_node(orig, prev, _pos) if _pos >= 0
        #   epos = prev.epos == noun.epos ? noun.epos : MtEpos::NP
        #   noun = init_node([prev, node, noun], epos: epos, attr: attr)
      else
        break
      end
    end

    {nn_node, _pos}
  end

  private def init_nn_nn_pair(head : MtNode, tail : MtNode, attr : MtAttr)
    epos = head.epos.nr? && tail.attr.sufx? ? head.epos : MtEpos::NN

    init_pair_node(head: head, tail: tail, epos: epos, attr: attr) do
      if epos.nr? && head.attr.nper?
        tail.epos = MtEpos::NH

        if defn = @mt_dict.get_defn?(tail.zstr, :NH, false)
          tail.attr = defn.attr
          tail.body = defn
        end

        flip = tail.attr.at_t? ? false : tail.attr.nloc?
      else
        flip = true
      end

      MtPair.new(head, tail, flip: flip)
    end
  end

  # private def cast_nn_tail_as_sufx(tail : MtAttr)
  # end

  def init_np_node(orig : Array(MtNode), np_node : MtNode, _pos : Int32 = orig.size - 2)
    attr = np_node.attr.turn_off(MtAttr[Sufx, Undb])

    while _pos >= 0
      node = orig.unsafe_fetch(_pos)

      case node.epos
      when .od?, .cp?, .ip?, .lcp?
        np_node = init_pair_node(head: node, tail: np_node, epos: :NP, attr: attr, flip: true)
      when .dp?
        np_node = init_dp_np_pair(np_node: np_node, dp_node: node)
      when .qp?, .clp?, .cd?
        np_node = init_qp_np_pair(np_node: np_node, qp_node: node)
      when .adjp?, .dnp?
        flip = !node.attr.at_h?
        np_node = init_pair_node(head: node, tail: np_node, epos: :NP, attr: attr, flip: flip)
      when .pn?
        at_h = pron_at_head?(pn_node: node, np_node: np_node)
        np_node = init_pair_node(head: node, tail: np_node, epos: :NP, attr: attr, flip: !at_h)
      else
        break
      end

      _pos &-= 1
    end

    {np_node, _pos}
  end

  private def pron_at_head?(pn_node : MtNode, np_node : MtNode)
    true
  end
end
