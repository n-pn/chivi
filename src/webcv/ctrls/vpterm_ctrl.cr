class CV::VptermCtrl < CV::BaseCtrl
  def lookup
    input = params.json("input").as_h

    hvmap = Hash(String, String).new do |h, k|
      h[k] = MtCore.cv_hanviet(k, apply_cap: false)
    end

    w_temp = params["temp"]? == "t"

    send_json do |jb|
      jb.object do
        input.each do |dname, words|
          words = words.as_a.map(&.to_s)

          if dname == "pin_yin"
            jb.field(dname, words.map { |w| {w, MtCore.cv_pin_yin(w)} }.to_h)
          else
            jb.field(dname) do
              entry = VpTermView.new(dname, words, hvmap, user: _viuser.uname, temp: w_temp)
              entry.to_json(jb)
            end
          end
        end
      end
    end
  end

  def upsert_entry
    dname = params["dname"]
    vdict = VpDict.load(dname)

    chset = VpTermForm.new(params, vdict, _viuser)
    chset.validate.try { |error| return halt!(403, error) }

    return halt!(401, "Nội dung không thay đổi!") unless vpterm = chset.save

    spawn do
      if vdict.kind.cvmtl?
        MtDict.upsert(dname[1..], vpterm)
      elsif vdict.kind.novel?
        VpHint.user_vals.append!(vpterm.key, vpterm.vals)
        VpHint.user_tags.append!(vpterm.key, vpterm.tags)
      end
    end

    spawn do
      next unless vdict.kind.novel? && dname[0] == '-'
      nvdict = Nvdict.load!(dname[1..])
      nvdict.update(dsize: vdict.size, utime: vpterm.utime)
    rescue err
      Log.error { err }
    end

    serv_json(vpterm, 201)
  end

  def upsert_batch
    halt! 404, "Chức năng đang hoàn thiện!"
  end
end
