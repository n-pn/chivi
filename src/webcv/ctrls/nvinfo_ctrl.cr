require "./_base_ctrl"

class CV::NvinfoCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(max: 24)

    query =
      Nvinfo.query
        .where("shield < 2")
        .filter_btitle(params["btitle"]?)
        .filter_author(params["author"]?)
        .filter_zseeds(params["sname"]?)
        .filter_genres(params["genre"]?)
        .filter_origin(params["origin"]?)
        .filter_cvuser(params["uname"]?, params["bmark"]?)

    query.sort_by(params.fetch_str("order", "access"))
    total = query.dup.limit(offset + limit * 3).offset(0).count

    limit = limit == 24 ? 25 : limit
    query.limit(limit).offset(offset).with_author

    set_cache :public, maxage: 10

    send_json({
      total: total,
      pgidx: pgidx,
      pgmax: (total - 1) // limit + 1,
      books: query.map { |x| NvinfoView.new(x, false) },
    })
  end

  def show : Nil
    bslug = params["bslug"]
    unless nvinfo = Nvinfo.load!(bslug)
      return halt!(404, "Quyển sách không tồn tại!")
    end

    nvinfo.bump! if _cvuser.privi >= 0
    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvinfo.id)

    nvseeds = nvinfo.nvseeds.to_a.sort_by!(&.zseed)
    if nvseeds.empty? || nvseeds.first.zseed != 0
      nvseeds.unshift(Nvseed.load!(nvinfo, 0))
    end

    if (ubmemo.lr_sname.empty?) && (nvseed = nvseeds.first?)
      if chinfo = nvseed.chinfo(0)
        ubmemo.lr_sname = nvseed.sname
        ubmemo.lr_chidx = -1
        ubmemo.lc_uslug = chinfo.trans.uslug
      else
        ubmemo.lr_sname = "chivi"
        ubmemo.lc_uslug = "thieu-chuong"
      end
    end

    set_cache :private, maxage: 30

    send_json do |jb|
      jb.object {
        jb.field "nvinfo" { NvinfoView.new(nvinfo, true).to_json(jb) }
        jb.field "ubmemo" { UbmemoView.new(ubmemo).to_json(jb) }
        jb.field "nvseed", nvseeds.map { |x| ChseedView.new(x) }
        jb.field "nvslug", nvinfo.bslug != bslug ? nvinfo.bslug : ""
      }
    end
  end

  # show related data for book front page
  def front
    unless nvinfo = Nvinfo.load!(params["bslug"])
      return halt!(404, "Quyển sách không tồn tại!")
    end

    yscrits =
      Yscrit.query
        .where("nvinfo_id = #{nvinfo.id}")
        .sort_by("score").limit(3)

    nvinfos =
      Nvinfo.query
        .where("author_id = #{nvinfo.author_id} AND id != #{nvinfo.id}")
        .sort_by("weight").limit(6)

    ubmemos =
      Ubmemo.query
        .where("nvinfo_id = #{nvinfo.id} AND status > 0")
        .order_by(utime: :desc)
        .with_cvuser
        .limit(100)

    send_json({
      crits: yscrits.map { |x| YscritView.new(x) },
      books: nvinfos.map { |x| NvinfoView.new(x, false) },
      users: ubmemos.map do |x|
        {
          u_dname: x.cvuser.uname,
          u_privi: x.cvuser.privi,
          _status: x.status_s,
        }
      end,
    })
  end

  def upsert
    return halt!(403, "Quyền hạn không đủ!") if _cvuser.privi < 3

    btitle_zh, author_zh = BookUtil.fix_names(params["btitle_zh"].strip, params["author_zh"].strip)

    author = Author.upsert!(author_zh)
    btitle = Btitle.upsert!(btitle_zh)

    nvinfo = Nvinfo.upsert!(author, btitle)

    params["bintro"]?.try { |x| nvinfo.set_zintro(TextUtil.split_text(x), true) }
    params["genres"]?.try { |x| nvinfo.set_genres(x.split(',').map(&.strip), true) }

    params["bcover"]?.try { |x| nvinfo.set_covers(x, force: true) }
    params["status"]?.try { |x| nvinfo.set_status(x.to_i, force: true) }

    nvinfo.save!

    log_upsert_action(params)
    send_json({bslug: nvinfo.bslug})
  end

  LOG_FILE = "var/pg_data/weblogs/#{Time.utc.to_s.split(' ', 2).first}.log"

  private def log_upsert_action(params)
    params = params.to_unsafe_h
    params.delete("_json")

    File.open(LOG_FILE, "a") do |io|
      data = {action: "upsert_nvinfo", cvuser: _cvuser.uname, params: params}
      io.puts(data.to_json)
    end
  end
end
