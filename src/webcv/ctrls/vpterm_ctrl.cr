class CV::VptermCtrl < CV::BaseCtrl
  def lookup
    input = params.json("input").as_h

    hvmap = Hash(String, String).new do |h, k|
      h[k] = MtCore.cv_hanviet(k, apply_cap: false)
    end

    send_json do |jb|
      jb.object do
        input.each do |dname, words|
          words = words.as_a.map(&.to_s)

          if dname == "pin_yin"
            jb.field(dname, words.map { |w| {w, MtCore.cv_pin_yin(w)} }.to_h)
          else
            jb.field(dname) do
              VpTermView.new(dname, words, hvmap, _cvuser.uname).to_json(jb)
            end
          end
        end
      end
    end
  end

  def upsert_entry
    dname = params["dname"]
    vpdict = VpDict.load(dname)

    ch_set = VpTermForm.new(params, vpdict, _cvuser)
    ch_set.validate.try { |error| return halt!(403, error) }
    return halt!(401, "Nội dung không thay đổi!") unless vpterm = ch_set.save?

    spawn do
      if vpdict.kind.cvmtl?
        MtDict.upsert(dname[1..], vpterm)
      elsif vpdict.kind.novel?
        VpHint.user_vals.append!(vpterm.key, vpterm.val)
        VpHint.user_tags.append!(vpterm.key, vpterm.attr.split(" "))
      end
    end

    spawn do
      next unless vpdict.kind.novel? && dname[0] == '-'
      nvdict = Nvdict.load!(dname[1..])
      nvdict.update(dsize: vpdict.size, utime: vpterm.utime)
    rescue err
      Log.error { err }
    end

    send_json(vpterm, 201)
  end

  def upsert_batch
    halt! 404, "Chức năng đang hoàn thiện!"
  end
end
