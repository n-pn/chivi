require "./_base_ctrl"

class CV::VptermCtrl < CV::BaseCtrl
  def lookup
    input = params.json("input").as_h
    uname = "!#{u_dname}"

    send_json do |jb|
      jb.object {
        input.each do |dname, words|
          cvmtl = load_cvmtl(dname, uname)
          vdict = VpDict.load(dname)

          jb.field(dname) {
            jb.object {
              words.as_a.each do |word|
                word = word.as_s
                if dname == "pin_yin"
                  jb.field(word, cvmtl.translit(word).to_s)
                else
                  jb.field(word) {
                    VpTermView.new(word, vdict, cvmtl, uname).to_json(jb)
                  }
                end
              end
            }
          }
        end
      }
    end
  end

  private def load_cvmtl(dname : String, uname : String)
    case dname
    when "pin_yin"          then MtCore.pin_yin_mtl
    when "hanviet"          then MtCore.hanviet_mtl
    when .starts_with?('$') then MtCore.generic_mtl(dname, uname)
    else                         MtCore.generic_mtl("combine", uname)
    end
  end

  def upsert_entry
    dname = params["dname"]
    scope = params["scope"]? || "novel"
    vdict = VpDict.load(dname, scope)

    _priv = params["_priv"]? == "true"
    unless vdict.allow?(_cvuser.privi, _priv)
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

    unless vdict.set!(vpterm)
      return halt!(401, "Nội dung không thay đổi!")
    end

    spawn do
      # add to suggestion
      add_to_suggest(vpterm.dup) if vdict.dtype > 1
      # add to qtran dict if entry is a person name
      add_to_combine(vpterm.dup) if vdict.dtype > 3 && dname != "combine"
    end

    send_json(vpterm, 201)
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
    halt! 404, "Chức năng đang hoàn thiện!"
  end
end
