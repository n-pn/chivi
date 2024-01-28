require "./_base"

class MT::AiCore
  private def init_node(data : RawCon, from : Int32 = 0) : MtNode
    zstr, orig = data.zstr, data.body
    epos, attr = MtEpos.parse_ctb(data.cpos, zstr)

    match_pos, match_any = @mt_dict.get_defn?(zstr, epos)

    if match_pos
      return MtNode.new(body: match_pos, zstr: zstr, epos: epos, attr: attr, from: from)
    end

    if match_any && (orig.is_a?(String) || (orig.size > 1 && epos.can_use_alt?))
      body = match_any.as_any(epos)
      return MtNode.new(body: body, zstr: zstr, epos: epos, attr: attr, from: from)
    end

    if orig.is_a?(String)
      vstr = translate_str(zstr, epos)
      body = @mt_dict.add_temp(zstr, vstr, attr, epos)
      return MtNode.new(body: body, zstr: zstr, epos: epos, attr: attr, from: from)
    end

    body = init_body(epos: epos, orig: orig, from: from)
    term = MtNode.new(body, zstr: zstr, epos: epos, attr: attr, from: from)

    case
    when epos.np?
      term = fix_np_node!(term, body)
    when epos.vp?
      term = fix_vp_node!(term, body)
    when body.is_a?(MtPair)
      fix_mt_pair!(term, body)
    end

    term
  end

  private def init_body(epos : MtEpos, orig : Array(RawCon), from : Int32 = 0)
    if orig.size == 1
      return init_node(orig.first, from: from)
    end

    if orig.size == 2
      head = init_node(orig.first, from: from)
      tail = init_node(orig.last, from: head.upto)
      return MtPair.new(head, tail)
    end

    list = [] of MtNode
    _idx = 0
    _max = orig.size

    while _idx < _max
      node = init_node(orig[_idx], from: from)
      _idx += 1

      unless _idx < _max && (match_pu = get_pu_match(node))
        list << node
        from = node.upto
        next
      end

      inner_list, _idx = group_pu_match(orig, head: node, epos: epos, match_pu: match_pu, _idx: _idx)

      if _idx == _max && list.empty?
        list = inner_list
      else
        node = MtNode.new(
          body: inner_list,
          zstr: inner_list.join(&.zstr),
          epos: inner_list[1].epos,
          from: inner_list.first.from
        )

        list << node
        from = node.upto
      end
    end

    case list.size
    when 1 then list.first
    when 2 then MtPair.new(list.first, list.last)
    else        list
    end
  end

  MATCH_PUNCT = {
    '＂' => '＂',
    '“' => '”',
    '‘' => '’',
    '〈' => '〉',
    '（' => '）',
    '［' => '］',
  }

  @[AlwaysInline]
  private def get_pu_match(node : MtNode)
    return unless node.epos.pu?
    MATCH_PUNCT[node.zstr[0]]?
  end

  private def group_pu_match(orig : Array(RawCon), head : MtNode,
                             epos : MtEpos, match_pu : Char, _idx = 1)
    inner_list = [] of MtNode

    from = head.upto
    _max = orig.size

    while _idx < _max
      node = init_node(orig[_idx], from: from)
      from = node.upto
      _idx += 1

      # TODO: check nested punct match?
      if node.epos.pu? && node.zstr[-1] == match_pu
        tail = node
        break
      else
        inner_list << node
      end
    end

    if inner_list.size > 1
      zstr = inner_list.join(&.zstr)
      epos = MtEpos::IP if inner_list.last.epos.pu?
      defn, dalt = @mt_dict.get_defn?(zstr, epos)
      inner = MtNode.new(body: defn || dalt || inner_list, zstr: zstr, epos: epos, from: inner_list.first.from)
    else
      inner = inner_list.first
    end

    {tail ? [head, inner, tail] : [head, inner], _idx}
  end
end
