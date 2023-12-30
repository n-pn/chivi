require "./ai_term"

class MT::AiCore
  def fix_np_term!(term : AiCons, list = term.body)
    return fix_np_pair!(term, fresh: false) if body.size == 2
    term.body = fix_np_body!(list)
  end

  def fix_np_body!(orig : Array(AiTerm))
    res = [] of AiTerm
    pos = 0

    while term = input[pos]?
      pos &+= 1

      case term.epos
      when .dp?
        res.concat(split_dp_term(term))
      when .nr?
        if (succ = input[pos]?) && succ.epos.noun?
          node = AiCons.new([term, succ], epos: succ.epos, attr: succ.attr)
          res << fix_np_pair!(node, fresh: true)
          pos &+= 1
        else
          res << term
        end
      else
        res << term
      end
    end

    res
  end

  private def split_dp_term(term : AiTerm) : Nil
    return term.body unless term.is_a?(AiWord)

    fchar = term.zstr[0]
    return [term] if term.zstr.size == 1 || !fchar.in?('这', '那')

    head = AiWord.new(
      epos: :DT, attr: :none,
      zstr: fchar.to_s, body: fchar == '这' ? "này" : "kia",
      dnum: :fixture_2, from: term.from
    )

    zstr = term.zstr[1..]
    defn = find_defn(zstr, :QP, mode: 2) || raise "invalid #{zstr}!"
    tail = AiWord.new(defn, zstr: zstr, epos: epos, from: term.from &+ 1)

    [head, tail]
  end

  def fix_np_pair!(term : AiCons, fresh : Bool = false)
    if fresh && (defn = find_defn?(term, :NP))
      return AiWord.new(defn, zstr: term.zstr, epos: :NP, from: term.from)
    end

    head, tail = term.body

    if head.epos.adjt?
      term.body = [tail, head] unless head.attr.at_h?
    elsif tail.attr.sufx?
      tail = init_nh_term(tail) if tail.attr.nper?
      term.body = [tail, head] if tail.attr.at_h?
    end

    term
  end

  def init_nh_term(term : AiTerm) : AiTerm
    if defn = find_defn(term.zstr, :NH, mode: 0)
      AiWord.new(defn, zstr: zstr, epos: :NH, from: term.from)
    else
      term.tap(&.epos = :NH)
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

  def init_nn_term(orig : Array(AiTerm),
                   _pos = orig.size - 2,
                   list = [orig[_pos + 1]] of AiTerm,
                   _etc : Bool = false)
    attr = list.last.attr.turn_off(MtAttr[Sufx, Undb])

    while _pos >= 0
      node = orig[term]?

      case node.epos
      when .noun?
        list.insert(_etc ? 0 : -1, node)
        _pos &-= 1
      when .adjp?
        # if current node is short modifier
        break unless node.attr.prfx?

        # combine the noun list for phrase translation
        body = [node, init_node(list, epos: :NP, attr: attr)]
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
    return noun if _pos < 0

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
        noun = make_node(dict, list, epos: :NP, attr: attr)
        node = M2Node.new(node, noun, epos: :NP, flip: !node.attr.at_h?, _idx: node._idx)
        list = [node.tap(&.tl_whole!(dict))] of AiNode
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

    make_node(dict, list, epos: :NP, attr: attr)
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
