class CV::QtransCtrl < CV::BaseCtrl
  def hanviet
    set_headers content_type: :text
    output = hv_translit(params["input"], true)
    params["mode"]? == "text" ? output.to_s(response) : output.to_str(response)
  end

  def mterror
    input = params.fetch_str("input")
    dname = params.fetch_str("dname", "combine")
    uname = params.fetch_str("uname", _cvuser.uname)

    set_headers content_type: :text

    cvmtl = MtCore.generic_mtl(dname, uname)
    cvmtl.cv_plain(input, cap_first: false).to_s(response)
    response << '\n'
    hv_translit(input, false).to_s(response)
  end

  private def hv_translit(input : String, apply_cap = true)
    MtCore.hanviet_mtl.translit(params["input"], apply_cap)
  end

  def convert
    type = params["type"]
    name = params["name"]

    data = QtranData.load!("#{type}--#{name}") do
      case type
      when "posts" then load_qtpost(name)
      when "notes" then load_qtnote(name)
      when "crits" then load_yscrit(name)
      when "repls" then load_ysrepl(name)
      when "texts" then load_zhtext(name)
      else              raise BadRequest.new("Thể loại #{type} không được hỗ trợ")
      end
    end

    return halt! 404, "Not found!" if data.input.empty?

    mode = QtranData::Mode.parse(params.fetch_str("mode", "node"))
    trad = params["trad"]? == "true"

    set_headers content_type: :text
    data.print_mtl(response, _cvuser.uname, mode: mode, trad: trad)
    data.print_raw(response) if params["_raw"]?
  end

  private def load_qtpost(name : String) : QtranData
    QtranData.from_file(name) || raise NotFound.new("Địa chỉ không tồn tại")
  end

  private def load_qtnote(name : String) : QtranData
    file_path = "var/qtnotes/#{name}.txt"
    raise NotFound.new("Tệp tin không tồn tại") unless File.exists?(file_path)
    QtranData.new(File.read_lines(file_path), "combine", "Tổng hợp")
  end

  private def load_yscrit(name : String) : QtranData
    crit_id = UkeyUtil.decode32(name)
    unless yscrit = Yscrit.find({id: crit_id})
      raise NotFound.new("Bình luận không tồn tại")
    end

    nvinfo = yscrit.nvinfo
    QtranData.new(parse_lines(yscrit.ztext), nvinfo.dname, nvinfo.vname)
  end

  private def load_ysrepl(name : String) : QtranData
    repl_id = UkeyUtil.decode32(name)
    unless ysrepl = Ysrepl.find({id: repl_id})
      raise NotFound.new("Phản hồi không tồn tại")
    end

    nvinfo = ysrepl.yscrit.nvinfo
    QtranData.new(parse_lines(ysrepl.ztext), nvinfo.dname, nvinfo.vname)
  end

  private def load_zhtext(name : String) : QtranData
    nvseed_id, chidx, cpart = QtranData.zhtext_ukey_decode(name)

    unless nvseed = Nvseed.find({id: nvseed_id})
      raise NotFound.new("Nguồn truyện không tồn tại")
    end

    unless chinfo = nvseed.chinfo(chidx - 1)
      raise NotFound.new("Chương tiết không tồn tại")
    end

    chtext = ChText.new(nvseed.sname, nvseed.snvid, chinfo)
    chdata = chtext.load!(cpart)
    QtranData.zhtext(nvseed.nvinfo, chdata.lines, chinfo.stats.parts, cpart)
  end

  def posts_upsert
    # TODO: save posts
    input = params.fetch_str("input")
    raise BadRequest.new("Dữ liệu quá lớn") if input.size > 10000

    lines = parse_lines(input)
    dname = params.fetch_str("dname", "combine")
    d_lbl = QtranData.get_d_lbl(dname)

    data = QtranData.new(lines, dname, d_lbl)
    ukey = params["ukey"]? || QtranData.qtpost_ukey

    data.save!("#{ukey}.txt", _cvuser.uname)
    QtranData::CACHE.set(ukey, data)

    serv_json({ukey: ukey})
  end

  private def parse_lines(ztext : String) : Array(String)
    ztext = ztext.gsub("\t", "  ")
    TextUtil.split_text(ztext, spaces_as_newline: false)
  end

  def webpage
    input = params["input"].gsub("\t", "  ")
    lines = input.split("\n").map! { |x| MtCore.trad_to_simp(x) }

    dname = params.fetch_str("dname", "combine")
    cvmtl = MtCore.generic_mtl(dname, _cvuser.uname)

    set_headers content_type: :text

    lines.each_with_index do |line, idx|
      response << '\n' if idx > 0
      cvmtl.cv_plain(line, cap_first: true).to_s(response)
    end
  end
end
