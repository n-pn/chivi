require "./ai_term"

class MT::AiCore
  def fix_np_term!(term : AiTerm, body = term.body)
    case body
    when AiPair
      term.body = fix_np_pair!(body)
    when MtDefn, AiTerm
      # Do nothing
    else
      term.body = fix_np_body!(body)
    end

    term
  end

  def fix_np_body!(orig : Array(AiTerm))
    body = [] of AiTerm
    _pos = orig.size &- 1

    while term = orig[_pos]?
      _pos &-= 1

      if _pos >= 0 && term.epos.noun?
        term, _pos = init_nn_term(orig, noun: term, _pos: _pos)
        term, _pos = init_np_term(orig, noun: term, _pos: _pos) if _pos >= 0
      end

      body.unshift(term)
    end

    body
  end

  def init_nn_term(orig : Array(AiTerm), noun : AiTerm, _pos = orig.size - 2)
    attr = noun.attr.turn_off(MtAttr[Sufx, Undb])

    while node = orig[_pos]?
      case node.epos
      when .noun?
        flip = flip_noun_pair?(head: node, tail: noun)
        noun = init_pair(head: node, tail: noun, epos: :NP, attr: attr, flip: flip)
        _pos &-= 1
      when .adjp?
        # if current node is short modifier
        break unless node.attr.prfx?
        _pos &-= 1

        # combine the noun list for phrase translation
        flip = !node.attr.at_h?
        noun = init_pair(head: node, tail: noun, epos: :NP, attr: attr, flip: flip)
      when .pu?
        # FIXME: check error in this part
        break if _pos == 0 || node.zstr[0] != '、'
        _pos &-= 1

        break unless (prev = orig[_pos - 1]?) && prev.epos.noun?
        _pos &-= 1

        prev, _pos = init_nn_term(orig, prev, _pos) if _pos >= 0
        noun = init_term([prev, node, noun], epos: :NP, attr: attr)
      else
        break
      end
    end

    {noun, _pos}
  end

  def init_np_term(orig : Array(AiTerm), noun : AiTerm, _pos : Int32 = orig.size - 2)
    attr = noun.attr.turn_off(MtAttr[Sufx, Undb])

    while node = orig[_pos]?
      case node.epos
      when .od?, .cp?, .ip?, .lcp?
        noun = init_pair(head: node, tail: noun, epos: :NP, attr: attr, flip: true)
      when .cd?, .clp?
        noun = init_pair(head: node, tail: noun, epos: :NP, attr: attr, flip: false)
      when .dp?
        # TODO: add dp to term
      when .qp?
        # add_qp_to_list(list, node, noun)
      when .adjp?
        flip = !node.attr.at_h?
        noun = init_pair(head: node, tail: noun, epos: :NP, attr: attr, flip: flip)
      when .dnp?
        flip = !node.attr.at_h?
        noun = init_pair(head: node, tail: noun, epos: :NP, attr: attr, flip: flip)
      when .pn?
        at_h = pron_at_head?(pron: node, noun: noun)
        noun = init_pair(head: node, tail: noun, epos: :NP, attr: attr, flip: !at_h)
      else
        break
      end

      _pos &-= 1
    end

    {noun, _pos}
  end

  private def split_dp_term(term : AiTerm) : Array(AiTerm)
    return term.body if term.is_a?(AiCons)

    fchar = term.zstr[0]
    return [term] of AiTerm if term.zstr.size == 1 || !fchar.in?('这', '那')

    head = AiWord.new(
      epos: :DT, attr: :none,
      zstr: fchar.to_s, body: fchar == '这' ? "này" : "kia",
      dnum: :fixture_2, from: term.from
    )

    zstr = term.zstr[1..]
    defn = find_defn(zstr, :QP, mode: 2) || raise "invalid #{zstr}!"
    tail = AiWord.new(defn, zstr: zstr, epos: :QP, from: term.from &+ 1)

    [head, tail] of AiTerm
  end

  def fix_dnp!(list : Array(AiTerm), attr : MtAttr)
    return {list, attr} unless list.size == 2
    head, tail = list

    if head.attr.at_h?
      attr |= :at_h
      return {list, attr}
    end
  end

  private def pron_at_head?(pron : AiTerm, noun : AiTerm)
    true
  end

  private def add_qp_to_list(list, qp_node, nn_node) : Nil
    m_node = qp_node.find_by_epos(:M) || qp_node
    MtPair.m_n_pair.fix_if_match!(m_node, nn_node)

    unless qp_node.first.epos.od?
      list.unshift(qp_node)
      return
    end

    case qp_node
    when M1Node
      list.push(qp_node)
    when M2Node
      list.push(qp_node.lhsn)
      list.unshift(qp_node.rhsn)
    else
      # TODO: handle M3Node and MxNode
      list.unshift(qp_node)
    end
  end
end
