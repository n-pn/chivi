require "./ai_term"

class MT::AiCore
  private def init_node(data : Array(AiTerm), cpos : MtEpos, attr : MtAttr = :none)
    return data.first if data.size == 1

    zstr = data.join(&.zstr)
    from = data.min_of(&.from)

    if defn = find_defn(zstr, epos, attr)
      AiWord.new(
        defn: defn, zstr: zstr,
        epos: epos, attr: attr,
        from: from)
    else
      AiCons.new(
        epos: epos, attr: attr,
        zstr: zstr, body: data,
        dnum: :autogen_0, from: from)
    end
  end

  private def init_node(data : RawCon, from : Int32 = 0) : AiTerm
    zstr, orig = data.zstr, data.body
    epos, attr = MtEpos.parse_ctb(data.cpos, zstr)

    if defn = find_defn(zstr, epos, attr)
      return AiWord.new(defn, zstr: zstr, epos: epos, attr: attr, from: from)
    elsif orig.is_a?(String)
      vstr = get_any_defn?(zstr) || QtCore.tl_hvword(zstr)
      return AiWord.new(
        epos: epos, attr: attr,
        zstr: zstr, body: vstr,
        dnum: :autogen_0, from: from)
    end

    body = init_cons_body(orig, from)

    term = AiCons.new(
      epos: epos, attr: attr,
      zstr: zstr, body: body,
      dnum: :unknown_0, from: from
    )

    return term.tap { |x| x.attr |= body.first.attr } if body.size == 1

    case epos
    when .np? then fix_np_term!(term, body)
      # when .vp? then fix_vp_term!(term, body)

    end

    term
  end

  MATCH_PUNCT = {
    '＂' => '＂',
    '“' => '”',
    '‘' => '’',
    '〈' => '〉',
    '（' => '）',
    '［' => '］',
  }

  private def init_cons_body(orig : Array(RawCon), from : Int32 = 0)
    prev_upto = from
    stack = [{[] of AiTerm, '\0'}]

    prev_upto = from

    orig.each do |rcon|
      node = init_node(rcon, from: prev_upto)
      prev_upto = node.upto

      pending, match_pu = stack.last

      if !node.epos.pu?
        pending << node.as(AiTerm)
      elsif node.zstr[-1] == match_pu
        pending << node.as(AiTerm)

        # for case that whole group is matching, just return the list
        return pending if pending.size == orig.size

        # else, generate new list
        term = init_pu_term(pending)
        stack.pop # remove the pending list
        stack.last[0] << term
      elsif match_pu = MATCH_PUNCT[node.zstr[0]]?
        stack << {[node] of AiTerm, match_pu}
      else
        pending << node.as(AiTerm)
      end
    end

    stack.flat_map(&.[0])
  end

  private def init_pu_term(list : Array(AiTerm)) : AiTerm
    # pp [list]

    zstr = list.join(&.zstr)
    from = list.first.from

    if list[-2].epos.pu?
      epos = MtEpos::IP
      attr = MtAttr::Capn
    else
      epos = MtEpos::X
      attr = MtAttr::None
    end

    if defn = find_defn(zstr, epos, attr)
      AiWord.new(defn: defn, zstr: zstr, epos: epos, attr: attr, from: from)
    else
      AiCons.new(epos: epos, attr: attr, body: list, zstr: zstr, from: from)
    end
  end
end
