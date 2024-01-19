# require "./ai_term"

class MT::AiCore
  def fix_np_term!(term : MtTerm, body = term.body)
    case body
    when MtDefn, MtTerm
      # Do nothing
    when MtPair
      term.body = fix_np_pair!(body)
    else
      term.body = fix_np_body!(body)
    end

    term
  end

  def fix_np_body!(orig : Array(MtTerm))
    body = [] of MtTerm
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

  def init_nn_term(orig : Array(MtTerm), noun : MtTerm, _pos = orig.size - 2)
    attr = noun.attr.turn_off(MtAttr[Sufx, Undb])

    while node = orig[_pos]?
      case node.epos
      when .noun?
        flip = flip_noun_pair?(head: node, tail: noun)
        noun = init_pair(head: node, tail: noun, epos: :NN, attr: attr, flip: flip)
        _pos &-= 1
      when .adjp?
        # if current node is short modifier
        break unless node.attr.prfx?
        _pos &-= 1

        # combine the noun list for phrase translation
        flip = !node.attr.at_h?
        noun = init_pair(head: node, tail: noun, epos: :NN, attr: attr, flip: flip)
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

  def init_np_term(orig : Array(MtTerm), noun : MtTerm, _pos : Int32 = orig.size - 2)
    attr = noun.attr.turn_off(MtAttr[Sufx, Undb])

    while node = orig[_pos]?
      case node.epos
      when .od?, .cp?, .ip?, .lcp?
        noun = init_pair(head: node, tail: noun, epos: :NP, attr: attr, flip: true)
      when .cd?, .clp?
        noun = init_pair(head: node, tail: noun, epos: :NP, attr: attr, flip: false)
      when .dp?
        noun = init_dp_np_pair(np_term: noun, dp_term: node)
      when .qp?
        noun = pair_noun_qp(np_term: noun, qp_term: node)
      when .adjp?, .dnp?
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

  private def pron_at_head?(pron : MtTerm, noun : MtTerm)
    true
  end
end
