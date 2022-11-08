class CV::NvinfoCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(max: 24)

    query =
      Nvinfo.query
        .where("shield < 2")
        .filter_btitle(params["btitle"]?)
        .filter_author(params["author"]?)
        .filter_chroot(params["chroot"]?)
        .filter_genres(params["genres"]?)
        .filter_tagged(params["tagged"]?)
        .filter_origin(params["origin"]?)
        .filter_status(params["status"]?)
        .filter_voters(params["voters"]?)
        .filter_rating(params["rating"]?)
        .filter_viuser(params["uname"]?, params["bmark"]?)

    query.sort_by(params.read_str("order", "access"))
    total = query.dup.limit(offset + limit * 3).offset(0).count

    limit = limit == 24 ? 25 : limit
    query.limit(limit).offset(offset).with_author

    set_cache :private, maxage: 5

    serv_json({
      total: total,
      pgidx: pgidx,
      pgmax: (total - 1) // limit + 1,
      books: NvinfoView.map(query),
    })
  end

  def load_prev_book(bslug : String)
    frags = bslug.split('-')
    return unless (last = frags.last?) && last.size == 4
    Nvinfo.find("bslug like '#{last}%'")
  end

  def show : Nil
    bslug = TextUtil.slugify(params["bslug"])

    unless nvinfo = Nvinfo.load!(bslug[0..7])
      load_prev_book(bslug).try { |x| return serv_text(x.bslug, 301) }
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

    serv_json do |jb|
      jb.object {
        jb.field "nvinfo" { NvinfoView.new(nvinfo, true).to_json(jb) }
        jb.field "ubmemo" { UbmemoView.new(ubmemo).to_json(jb) }
      }
    end
  end

  # show related data for book front page
  def front
    unless nvinfo = Nvinfo.load!(params["bslug"])
      return halt!(404, "Quyển sách không tồn tại!")
    end

    Nvstat.inc_info_view(nvinfo.id)

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

    send_json({
      books: nvinfos.map { |x| NvinfoView.new(x, false) },
      users: ubmemos.map do |x|
        {
          u_dname: x.viuser.uname,
          u_privi: x.viuser.privi,
          _status: x.status_s,
        }
      end,
    })
  end

  def edit
    unless nvinfo = Nvinfo.load!(params["bslug"])
      return halt!(404, "Quyển sách không tồn tại!")
    end

    serv_json({
      genres: nvinfo.vgenres,
      bintro: nvinfo.zintro,
      bcover: nvinfo.scover,
    })
  end

  def upsert
    raise Unauthorized.new("Cần quyền hạn tối thiểu là 2") if _viuser.privi < 2

    nvinfo = NvinfoForm.new(params, "@" + _viuser.uname).save
    update_db_index(nvinfo)

    Nvinfo.cache!(nvinfo)

    spawn do
      `bin/bcover_cli single -i "#{nvinfo.scover}" -n #{nvinfo.bcover}`
      body = params.to_unsafe_h.tap(&.delete("_json"))
      CtrlUtil.log_user_action("nvinfo-upsert", body, _viuser.uname)
    end

    serv_json({bslug: nvinfo.bslug})
  rescue err
    serv_text(err.message, 400)
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

  def delete
    return halt!(403, "Quyền hạn không đủ!") if _viuser.privi < 4
    unless nvinfo = Nvinfo.load!(params["bslug"])
      return halt!(404, "Quyển sách không tồn tại!")
    end

    nvinfo.delete
    Ubmemo.query.where(nvinfo_id: nvinfo.id).to_delete.execute
    send_json({message: "ok"})
  end
end
