require "./base_ctrl"

class CV::VptermCtrl < CV::BaseCtrl
  def upsert_entry
    dname = params["dname"]
    scope = params["scope"]? || "basic"
    vdict = VpDict.load(dname, scope)

    _priv = params["_priv"]? == "true"
    unless vdict.allow?(u_privi, _priv)
      return halt!(403, "Không đủ quyền hạn để sửa từ!")
    end

    key = params.fetch_str("key").gsub("\t", " ").strip
    val = params.fetch_str("val").tr("", "").split(" | ").map(&.strip)

    if vdict.dtype == 2 && VpDict.fixture.find(key)
      return halt!(403, "Không thể sửa được từ khoá cứng!")
    end

    attr = params.fetch_str("attr", "")
    rank = params.fetch_str("rank", "").to_u8? || 3_u8

    uname = _priv ? "!" + u_dname : u_dname
    vpterm = VpTerm.new(key, val, attr, rank, uname: uname)

    return halt!(501, "Nội dung không thay đổi!") unless vdict.set!(vpterm)

    # add to suggestion
    add_to_suggest(vpterm.dup) if vdict.dtype > 1
    # add to qtran dict if entry is a person name
    add_to_combine(vpterm.dup) if vdict.dtype > 3 && dname != "combine"

    json_view(vpterm)
  rescue err
    Log.error { err.inspect_with_backtrace }
    halt! 500, err.message
  end

  private def add_to_suggest(term : VpTerm)
    VpDict.suggest.find(term.key).try do |prev|
      term.val.concat(prev.val).uniq!
    end

    VpDict.suggest.set!(term)
  end

  private def add_to_combine(term : VpTerm)
    return unless term.key.size > 1 && term.ptag.person?
    VpDict.combine.set!(term)
  end

  def upsert_batch
    halt! 404, "Unsupported!"
  end
end
