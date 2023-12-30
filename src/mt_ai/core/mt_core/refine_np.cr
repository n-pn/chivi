require "./ai_term"

class MT::AiCore
  def fix_np_term!(term : AiCons, body = term.body)
    return fix_np_pair!(term, fresh: false) if body.size == 2
    term.body = fix_np_body!(body)
    term
  end

  def fix_np_body!(orig : Array(AiTerm))
    body = [] of AiTerm
    _pos = orig.size &- 1

    while term = orig[_pos]?
      _pos &-= 1

      case term.epos
      when .noun?
        noun, _pos = init_nn_term(orig, _pos: _pos, list: [term] of AiTerm)
        body.unshift(noun)
      else
        body.unshift(noun)
      end
    end

    body
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

  def fix_np_pair!(term : AiCons, fresh : Bool = false)
    if fresh && (defn = find_defn(term.zstr, :NP))
      return AiWord.new(defn, zstr: term.zstr, epos: :NP, from: term.from)
    end

    head, tail = term.body
    # pp [head, tail]

    case
    when head.epos.adjt?
      term.body = [tail, head] of AiTerm unless head.attr.at_h?
    when tail.attr.sufx?
      tail = init_nh_term(tail) if tail.attr.nper?
      term.body = tail.attr.at_h? ? [tail, head] of AiTerm : [head, tail] of AiTerm
    end

    term
  end

  def init_nn_term(orig : Array(AiTerm),
                   _pos = orig.size - 2,
                   list = [orig[_pos + 1]] of AiTerm,
                   _etc : Bool = false)
    attr = list.last.attr.turn_off(MtAttr[Sufx, Undb])

    while node = orig[_pos]?
      case node.epos
      when .noun?
        list.insert(_etc ? 0 : -1, node)
        _pos &-= 1
      when .adjp?
        # if current node is short modifier
        break unless node.attr.prfx?

        # combine the noun list for phrase translation
        body = [node, init_node(list, epos: :NP, attr: attr)] of AiTerm
        noun = AiCons.new(body, epos: :NP, attr: attr)
        list = [fix_np_pair!(noun, fresh: true)] of AiTerm

        _pos &-= 1
      when .pu?
        # FIXME: check error in this part
        break if _pos == 0 || node.zstr[0] != '､'

        list.unshift(node)
        _pos &-= 1

        prev = @orig[_pos]
        break unless prev.epos.noun?
        _pos &-= 1

        prev = init_nn_term(orig, _pos, [prev] of AiTerm, _etc) if _pos >= 0
        list.unshift(prev)
      else
        break
      end
    end

    noun = init_node(list, cpos: :NP, attr: attr)
    return {noun, _pos} if _pos < 0

    init_np_term(orig, [noun of AiTerm], _pos: _pos)
  end

  def init_np_term(orig : Array(AiTerm),
                   list : Array(AiTerm),
                   _pos : Int32 = 0)
    noun = list.last
    attr = noun.attr.turn_off(MtAttr[Sufx, Undb])

    while node = orig[_pos]?
      case node.epos
      when .od?, .cp?, .ip?, .lcp?
        list.push(node)
      when .cd?, .clp?
        list.unshift(node)
      when .qp?
        add_qp_to_list(list, node, noun)
      when .adjp?
        body = [node, init_node(list, epos: :NP, attr: attr)]
        noun = AiCons.new(body, epos: :NP, attr: attr)
        list = [fix_np_pair!(noun, fresh: true)] of AiTerm
      when .dp?
        # TODO: add dp to term
      when .dnp?, .dt?, .dp?
        list.insert(node.attr.at_h? ? 0 : -1, node)
      when .pn?
        at_h = pron_at_head?(pron: node, noun: noun)
        list.insert(at_h ? 0 : -1, node)
      else
        break
      end

      _pos &-= 1
    end

    {init_node(dict, list, epos: :NP, attr: attr), _pos}
  end

  def init_nh_term(term : AiTerm) : AiTerm
    if defn = find_defn(term.zstr, :NH, mode: 0)
      AiWord.new(defn, zstr: term.zstr, epos: :NH, from: term.from)
    else
      term.epos = MtEpos::NH
      term
    end
  end

  def fix_dnp!(list : Array(AiTerm), attr : MtAttr)
    return {list, attr} unless list.size == 2
    head, tail = list

    if head.attr.at_h?
      attr |= :at_h
      return {list, attr}
    end
  end

  private def pron_at_head?(pron : AiNode, noun : AiNode)
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
