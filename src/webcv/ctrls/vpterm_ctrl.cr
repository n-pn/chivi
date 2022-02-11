require "./_base_ctrl"

class CV::VptermCtrl < CV::BaseCtrl
  def lookup
    input = params.json("input").as_h
    hvmap = Hash(String, String).new { |h, k| h[k] = MtCore.cv_hanviet(k) }

    send_json do |jb|
      jb.object do
        input.each do |dname, words|
          words = words.as_a.map(&.to_s)

          if dname == "pin_yin"
            jb.field(dname, words.map { |w| {w, MtCore.cv_pin_yin(w)} }.to_h)
          else
            jb.field(dname) { VpTermView.new(dname, words, hvmap, u_dname).to_json(jb) }
          end
        end
      end
    end
  end

  def upsert_entry
    dname = params["dname"]
    vdict = VpDict.load(dname)
    chset = VpTermForm.new(params, vdict, _cvuser)

    if error = chset.validate
      return halt!(403, error)
    end

    unless vpterm = chset.save?
      return halt!(401, "Nội dung không thay đổi!")
    end

    if vdict.dtype == 1
      MtDict.upsert(dname[1..], vpterm) if dname[0] == '~'
    else
      # add to suggestion
      add_to_suggest(vpterm.dup) if vdict.dtype > 1 && dname != "suggest"
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
