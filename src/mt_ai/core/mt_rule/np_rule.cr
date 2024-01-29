# require "./ai_term"

class MT::AiCore
  def fix_np_node!(term : MtNode, body = term.body) : MtNode
    return term if body.is_a?(MtDefn) || body.is_a?(MtNode)
    body = [body.head, body.tail] if body.is_a?(MtPair)

    new_body = [] of MtNode
    _pos = body.size &- 1

    while _pos >= 0
      node = body[_pos]
      _pos &-= 1

      if _pos >= 0 && node.epos.noun?
        node, _pos = init_nn_term(body, noun: node, _pos: _pos)
        node, _pos = init_np_term(body, noun: node, _pos: _pos) if _pos >= 0
      end

      new_body.unshift(node)
    end

    if new_body.size > 1
      term.body = new_body
    elsif new_body.first.epos.np?
      term.attr |= new_body.first.attr
      term.body = new_body.first
    else
      term.body = new_body
      term.attr |= new_body.first.attr
    end

    term
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

  def init_nn_term(orig : Array(MtNode), noun : MtNode, _pos = orig.size - 2)
    attr = noun.attr.turn_off(MtAttr[Sufx, Undb])

    while _pos >= 0
      node = orig[_pos]

      case node.epos
      when .noun?
        noun = init_nn_nn_pair(head: node, tail: noun, attr: attr)
        _pos &-= 1
      when .adjp?
        # if current node is short modifier
        break unless node.attr.prfx?
        _pos &-= 1

        # combine the noun list for phrase translation
        flip = !node.attr.at_h?
        noun = init_pair_node(head: node, tail: noun, epos: :NN, attr: attr, flip: flip)
      when .pu?
        # FIXME: check error in this part
        break if _pos == 0 || node.zstr[0] != '、'
        _pos &-= 1

        break unless (prev = orig[_pos - 1]?) && prev.epos.noun?
        _pos &-= 1

        prev, _pos = init_nn_term(orig, prev, _pos) if _pos >= 0
        epos = prev.epos == noun.epos ? noun.epos : MtEpos::NP
        noun = init_term([prev, node, noun], epos: epos, attr: attr)
      else
        break
      end
    end

    {noun, _pos}
  end

  private def init_nn_nn_pair(head : MtNode, tail : MtNode, attr : MtAttr)
    init_pair_node(head: head, tail: tail, epos: :NN, attr: attr) do
      if head.attr.ndes? || head.attr.ntmp?
        flip = true
      elsif tail.attr.sufx? && tail.attr.nper?
        tail.epos = MtEpos::NH

        if defn = @mt_dict.get_defn?(tail.zstr, :NH)[0]
          tail.body = defn
          tail.attr = defn.attr
        end

        flip = !tail.attr.at_t?
      else
        flip = !tail.attr.at_t?
      end

      MtPair.new(head, tail, flip: flip)
    end
  end

  # private def cast_nn_tail_as_sufx(tail : MtAttr)
  # end

  def init_np_term(orig : Array(MtNode), noun : MtNode, _pos : Int32 = orig.size - 2)
    attr = noun.attr.turn_off(MtAttr[Sufx, Undb])

    while _pos >= 0
      node = orig.unsafe_fetch(_pos)

      case node.epos
      when .od?, .cp?, .ip?, .lcp?
        noun = init_pair_node(head: node, tail: noun, epos: :NP, attr: attr, flip: true)
      when .cd?, .clp?
        noun = init_pair_node(head: node, tail: noun, epos: :NP, attr: attr, flip: false)
      when .dp?
        noun = init_dp_np_pair(np_term: noun, dp_term: node)
      when .qp?
        noun = init_qp_np_pair(np_term: noun, qp_term: node)
      when .adjp?, .dnp?
        flip = !node.attr.at_h?
        noun = init_pair_node(head: node, tail: noun, epos: :NP, attr: attr, flip: flip)
      when .pn?
        at_h = pron_at_head?(pron: node, noun: noun)
        noun = init_pair_node(head: node, tail: noun, epos: :NP, attr: attr, flip: !at_h)
      else
        break
      end

      _pos &-= 1
    end

    {noun, _pos}
  end

  private def pron_at_head?(pron : MtNode, noun : MtNode)
    true
  end
end
