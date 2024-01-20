require "./_base"

class MT::AiCore
  private def init_body(epos : MtEpos, orig : Array(RawCon), from : Int32 = 0)
    if orig.size == 1
      return init_node(orig.first, from: from)
    end

    if orig.size == 2
      head = init_node(orig.first, from: from)
      tail = init_node(orig.last, from: head.upto)
      return MtPair.new(head, tail)
    end

    list = [] of MtTerm
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
        node = MtTerm.new(
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
  private def get_pu_match(node : MtTerm)
    return unless node.epos.pu?
    MATCH_PUNCT[node.zstr[0]]?
  end

  private def group_pu_match(orig : Array(RawCon), head : MtTerm,
                             epos : MtEpos, match_pu : Char, _idx = 1)
    inner_list = [] of MtTerm

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
      inner = MtTerm.new(body: defn || dalt || inner_list, zstr: zstr, epos: epos, from: inner_list.first.from)
    else
      inner = inner_list.first
    end

    {tail ? [head, inner, tail] : [head, inner], _idx}
  end
end
