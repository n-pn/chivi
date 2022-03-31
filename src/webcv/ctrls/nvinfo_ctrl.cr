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
    query.limit(limit).offset(offset).with_author.with_btitle

    set_cache :public, maxage: 10

    send_json({
      total: total,
      pgidx: pgidx,
      pgmax: (total - 1) // limit + 1,
      books: query.map { |x| NvinfoView.new(x, false) },
    })
  end

  def show : Nil
    unless nvinfo = Nvinfo.find({bslug: params["bslug"]})
      return halt!(404, "Quyển sách không tồn tại!")
    end

    nvinfo.bump! if _cvuser.privi >= 0
    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvinfo.id)

    zhbooks = nvinfo.zhbooks.to_a.sort_by!(&.zseed)
    if zhbooks.empty? || zhbooks.first.zseed != 0
      zhbooks.unshift(Nvseed.load!(nvinfo, 0))
    end

    if (ubmemo.lr_sname.empty?) && (zhbook = zhbooks.first?)
      if chinfo = zhbook.chinfo(0)
        ubmemo.lr_sname = zhbook.sname
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
        jb.field "ubmemo" { UbmemoView.render(jb, ubmemo) }
        jb.field "nvseed", zhbooks.map { |x| ChseedView.new(x) }
      }
    end
  end

  # show related data for book front page
  def front
    nvinfo = Nvinfo.load!(params["bhash"])

    yscrits =
      Yscrit.query
        .where("nvinfo_id = #{nvinfo.id}")
        .sort_by("stars").limit(3)

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

    btitle_zname, author_zname = BookUtil.fix_names(params["btitle"].strip, params["author"].strip)
    author = Author.upsert!(author_zname)
    nvinfo = Nvinfo.upsert!(author, btitle_zname)

    params["bintro"]?.try { |x| nvinfo.set_zintro(TextUtil.split_text(x), true) }
    params["genres"]?.try { |x| nvinfo.set_zgenre(x.split(' ').map(&.strip), true) }

    params["bcover"]?.try { |x| nvinfo.set_bcover(x, force: true) }
    params["status"]?.try { |x| nvinfo.set_status(x.to_i, force: true) }

    nvinfo.save!

    log_upsert_action(params)
    send_json({bslug: nvinfo.bslug})
  end

  LOG_FILE = "var/_ulogs/#{Time.utc.to_s.split(' ', 2).first}.log"

  private def log_upsert_action(params)
    params = params.to_unsafe_h
    params.delete("_json")

    File.open(LOG_FILE, "a") do |io|
      data = {action: "upsert_nvinfo", cvuser: _cvuser.uname, params: params}
      io.puts(data.to_json)
    end
  end
end
