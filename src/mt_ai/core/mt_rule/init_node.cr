require "./_base"

class MT::AiCore
  private def init_node(data : RawCon, from : Int32 = 0) : MtTerm
    zstr, orig = data.zstr, data.body
    epos, attr = MtEpos.parse_ctb(data.cpos, zstr)

    match_pos, match_any = @mt_dict.get_defn?(zstr, epos)

    if match_pos
      return MtTerm.new(body: match_pos, zstr: zstr, epos: epos, attr: attr, from: from)
    end

    if match_any && (orig.is_a?(String) || (orig.size > 1 && epos.can_use_alt?))
      body = match_any.as_any
      return MtTerm.new(body: body, zstr: zstr, epos: epos, attr: attr, from: from)
    end

    if orig.is_a?(String)
      vstr = translate_str(zstr, epos)
      body = @mt_dict.add_temp(zstr, vstr, attr, epos)
      return MtTerm.new(body: body, zstr: zstr, epos: epos, attr: attr, from: from)
    end

    body = init_body(epos: epos, orig: orig, from: from)
    term = MtTerm.new(body, zstr: zstr, epos: epos, attr: attr, from: from)

    case epos
    when .np? then fix_np_term!(term, body)
      # when .vp? then fix_vp_term!(term, body)

    end

    term
  end

  private def init_pair(head : MtTerm, tail : MtTerm,
                        epos : MtEpos, attr : MtAttr = tail.attr,
                        zstr = "#{head.zstr}#{tail.zstr}", &)
    body = init_defn(zstr, epos: epos, attr: attr) || yield
    MtTerm.new(body: body, zstr: zstr, epos: epos, attr: attr, from: head.from)
  end

  private def init_pair(head : MtTerm, tail : MtTerm,
                        epos : MtEpos, attr : MtAttr = tail.attr,
                        zstr = "#{head.zstr}#{tail.zstr}", flip : Bool = false)
    init_pair(head: head, tail: tail, epos: epos, attr: attr, zstr: zstr) do
      MtPair.new(head, tail, flip: flip)
    end
  end

  private def init_term(list : Array(MtTerm),
                        epos : MtEpos, attr : MtAttr = :none,
                        zstr = list.join(&.zstr), from = list[0].from)
    body = init_defn(zstr, epos, attr) || begin
      case list.size
      when 1 then list[0]
      when 2 then MtPair.new(list[0], list[1])
      else        list
      end
    end

    MtTerm.new(body: body, zstr: zstr, epos: epos, attr: attr, from: from)
  end

  def init_defn(zstr : String, epos : MtEpos, attr : MtAttr = :none)
    match, _fuzzy = @mt_dict.get_defn?(zstr, epos)
    return match if match

    return unless vstr = translate_str(zstr, epos)
    @mt_dict.add_temp(zstr, vstr, attr, epos)
  end
end
