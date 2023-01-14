require "../_ctrl_base"
require "./vpterm_form"
require "../../../mt_v1/mt_core"

class CV::VptermCtrl < CV::BaseCtrl
  base "/api/terms"

  @[AC::Route::POST("/query", body: :form)]
  def lookup(form : Hash(String, Array(String)), temp : Bool = false)
    hvmap = Hash(String, String).new do |h, k|
      h[k] = MtCore.cv_hanviet(k, apply_cap: false)
    end

    output = form.map do |dname, words|
      if dname == "pin_yin"
        value = words.map { |w| {w, MtCore.cv_pin_yin(w)} }.to_h
      else
        value = VpTermView.new(dname, words, hvmap, user: _viuser.uname, temp: temp)
      end

      {dname, value}
    end

    render json: output.to_h
  end

  @[AC::Route::POST("/entry", body: :form)]
  def upsert_entry(form : VpTermForm)
    vdict = VpDict.load(form.dname)

    form.dict = vdict
    form.user = _viuser

    form.validate.try { |error| raise Unauthorized.new(error) }
    raise BadRequest.new("Nội dung không thay đổi!") unless vpterm = form.save

    spawn do
      if vdict.kind.mt_v2?
        MtDict.upsert(form.dname[1..], vpterm)
      elsif vdict.kind.novel?
        VpHint.user_vals.append!(vpterm.key, vpterm.vals)
        VpHint.user_tags.append!(vpterm.key, vpterm.tags)
      end
    end

    spawn do
      next unless vdict.kind.novel? && form.dname[0] == '-'
      nvdict = Nvdict.load!(form.dname[1..])
      nvdict.update(dsize: vdict.size, utime: vpterm.utime)
    rescue err
      Log.error { err }
    end

    spawn log_upsert_entry(vpterm, form)
    render :accepted, json: vpterm
  end

  LOG_DIR = "var/dicts/ulogs"
  Dir.mkdir_p(LOG_DIR)

  private def log_upsert_entry(entry, form)
    log_file = "#{LOG_DIR}/#{Time.local.to_s("%F")}.jsonl"

    File.open(log_file, "a") do |io|
      {
        entry.utime, form.dname,
        entry.key, entry.vals, entry.tags,
        entry.prio, entry.uname, entry._mode,
        form._raw, form._idx,
      }.to_json(io)

      io << '\n'
    end
  end

  @[AC::Route::POST("/batch")]
  def upsert_batch
    render :method_not_allowed, text: "Chức năng đang hoàn thiện!"
  end
end
