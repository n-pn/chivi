require "../_ctrl_base"
require "./nvinfo_form"

class CV::NvinfoCtrl < CV::BaseCtrl
  base "/api/books"

  @[AC::Route::GET("/")]
  def index(
    order : String = "access",
    pg pg_no : Int32 = 1, lm limit : Int32 = 10,
    btitle : String? = nil, author : String? = nil,
    chroot : String? = nil, origin : String? = nil,
    genres : String? = nil, tagged : String? = nil,
    voters : Int32? = nil, rating : Int32? = nil,
    uname : String? = nil, bmark : String? = nil,
    status : Int32? = nil
  )
    limit = 25 if limit >= 24
    offset = CtrlUtil.offset(pg_no, limit)

    query = Nvinfo.query.where("shield < 2").sort_by(order)
    query.filter_btitle(btitle)
    query.filter_author(author)
    query.filter_chroot(chroot)
    query.filter_genres(genres)
    query.filter_tagged(tagged)
    query.filter_origin(origin)

    query.where("status = ?", status &- 1) if status
    query.where("voters >= ?", voters) if voters
    query.where("rating >= ?", rating) if rating
    query.filter_viuser(uname, bmark) if uname && bmark

    total = query.dup.limit(offset + limit * 3).offset(0).count
    query.limit(limit).offset(offset).with_author

    render json: {
      total: total,
      pgidx: pg_no,
      pgmax: (total - 1) // limit + 1,
      books: NvinfoView.map(query),
    }
  end

  private def load_prev_book(bslug : String)
    frags = bslug.split('-')
    return unless (last = frags.last?) && last.size == 4
    Nvinfo.find("bslug like '#{last}%'")
  end

  @[AC::Route::GET("/:bslug")]
  def show(bslug : String) : Nil
    bslug = TextUtil.slugify(bslug)

    unless nvinfo = Nvinfo.load!(bslug[0..7])
      load_prev_book(bslug).try { |x| render 301, text: x.bslug; return }
      raise NotFound.new("Quyển sách không tồn tại!")
    end

    nvinfo.bump! if _viuser.privi >= 0
    ubmemo = Ubmemo.find_or_new(_viuser.id, nvinfo.id)

    if ubmemo.lr_sname.empty?
      ubmemo.lr_sname = "=base"
      base_seed = Chroot.load!(nvinfo, "=base", force: true)
      base_seed.reload_base! if base_seed.stage < 2

      if chinfo = base_seed.chinfo(1)
        ubmemo.lr_chidx = -1
        ubmemo.lc_uslug = chinfo.trans.uslug
      else
        ubmemo.lc_uslug = "-"
      end
    end

    render json: {
      nvinfo: NvinfoView.new(nvinfo, true),
      ubmemo: UbmemoView.new(ubmemo),
    }
  end

  # show related data for book front page
  @[AC::Route::GET("/:bslug/front")]
  def front(bslug : String)
    unless nvinfo = Nvinfo.load!(bslug)
      raise NotFound.new("Quyển sách không tồn tại!")
    end

    # spawn Nvstat.inc_info_view(nvinfo.id)

    nvinfos =
      Nvinfo.query
        .where("author_id = #{nvinfo.author_id} AND id != #{nvinfo.id}")
        .sort_by("weight").limit(6)

    ubmemos =
      Ubmemo.query
        .where("nvinfo_id = #{nvinfo.id} AND status > 0")
        .order_by(utime: :desc)
        .with_viuser
        .limit(100)

    render json: {
      books: nvinfos.map { |x| NvinfoView.new(x, false) },
      users: ubmemos.map { |x| {u_dname: x.viuser.uname, u_privi: x.viuser.privi, _status: x.status_s} },
    }
  end

  @[AC::Route::GET("/:bslug/+edit")]
  def edit(bslug : String)
    unless nvinfo = Nvinfo.load!(params["bslug"])
      raise NotFound.new("Quyển sách không tồn tại!")
    end

    {
      genres: nvinfo.vgenres,
      bintro: nvinfo.zintro,
      bcover: nvinfo.scover,
    }
  end

  @[AC::Route::POST("/")]
  def upsert
    unless _viuser.can?(:level2)
      raise Unauthorized.new("Cần quyền hạn tối thiểu là 2")
    end

    nvinfo = NvinfoForm.new(params, "@" + _viuser.uname).save
    spawn update_db_index(nvinfo)

    Nvinfo.cache!(nvinfo)

    spawn do
      `bin/bcover_cli single -i "#{nvinfo.scover}" -n #{nvinfo.bcover}`
      CtrlUtil.log_user_action("nvinfo-upsert", params.to_h, _viuser.uname)
    end

    {bslug: nvinfo.bslug}
  rescue err
    Log.error(exception: err) { err.message }
    render 400, text: err.message
  end

  private def update_db_index(nvinfo : Nvinfo)
    DB.open("sqlite3://var/dicts/index.db") do |db|
      args = [
        -nvinfo.id.to_i,
        "-" + nvinfo.bhash,
        nvinfo.bslug,
        nvinfo.vname,
        "Từ điển riêng cho bộ truyện [#{nvinfo.vname}]",
      ]

      db.exec <<-SQL, args: args
        insert or ignore into dicts(id, name, slug, label, intro)
        values (?, ?, ?, ?, ?)
      SQL
    end
  end

  @[AC::Route::DELETE("/:bslug")]
  def delete(bslug : String)
    unless _viuser.can?(:level4)
      raise Unauthorized.new("Cần quyền hạn tối thiểu là 4")
    end

    unless nvinfo = Nvinfo.load!(bslug)
      raise NotFound.new("Quyển sách không tồn tại!")
    end

    nvinfo.delete
    Ubmemo.query.where(nvinfo_id: nvinfo.id).to_delete.execute

    {msg: "ok"}
  end
end
