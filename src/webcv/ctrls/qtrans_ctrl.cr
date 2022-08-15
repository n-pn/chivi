class CV::QtransCtrl < CV::BaseCtrl
  def hanviet
    set_headers content_type: :text
    output = hv_translit(params["input"], true)
    params["mode"]? == "text" ? output.to_txt(response) : output.to_mtl(response)
  end

  def mterror
    input = params.read_str("input")
    dname = params.read_str("dname", "combine")
    uname = params.read_str("uname", _viuser.uname)

    set_headers content_type: :text

    caps = params["caps"]? == "t"

    cvmtl = MtCore.generic_mtl(dname, uname)
    cvmtl.cv_plain(input, cap_first: caps).to_txt(response)
    response << '\n'
    hv_translit(input, caps).to_txt(response)
  end

  private def hv_translit(input : String, apply_cap = true)
    MtCore.hanviet_mtl.translit(params["input"], apply_cap)
  end

  def convert
    type = params["type"]
    name = params["name"]

    stale = params["_new"]? ? Time.utc + 10.minutes : Time.utc
    data = QtranData.load!(type, name, stale: stale)

    return halt! 404, "Not found!" if data.input.empty?

    mode = QtranData::Format.parse(params.read_str("mode", "node"))
    trad = params["trad"]? == "t"
    user = params["user"]? || _viuser.uname

    set_headers content_type: :text
    engine = data.make_engine(user, with_temp: params["temp"]? == "t")
    data.print_mtl(engine, response, format: mode, title: type == "chaps", trad: trad)
    data.print_raw(response) if params["_raw"]?
  end

  def posts_upsert
    # TODO: save posts
    input = params.read_str("input")
    raise BadRequest.new("Dữ liệu quá lớn") if input.size > 10000

    lines = QtranData.parse_lines(input)
    dname = params.read_str("dname", "combine")
    d_lbl = QtranData.get_d_lbl(dname)

    data = QtranData.new(lines, dname, d_lbl)
    ukey = params["ukey"]? || QtranData.post_ukey

    data.save!(ukey)
    QtranData::CACHE.set("posts/" + ukey, data)

    serv_json({ukey: ukey})
  end

  def webpage
    input = params["input"].gsub("\t", "  ")
    lines = input.split("\n").map! { |x| MtCore.trad_to_simp(x) }

    dname = params.read_str("dname", "combine")
    cvmtl = MtCore.generic_mtl(dname, _viuser.uname)

    set_headers content_type: :text

    lines.each_with_index do |line, idx|
      response << '\n' if idx > 0
      cvmtl.cv_plain(line, cap_first: true).to_txt(response)
    end
  end
end
