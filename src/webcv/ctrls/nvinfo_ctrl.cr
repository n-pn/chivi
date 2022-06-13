class CV::NvinfoCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(max: 24)

    query =
      Nvinfo.query
        .where("shield < 2")
        .filter_btitle(params["btitle"]?)
        .filter_author(params["author"]?)
        .filter_nvseed(params["sname"]?)
        .filter_genres(params["genre"]?)
        .filter_tagged(params["tagged"]?)
        .filter_origin(params["origin"]?)
        .filter_cvuser(params["uname"]?, params["bmark"]?)

    query.sort_by(params.fetch_str("order", "access"))
    total = query.dup.limit(offset + limit * 3).offset(0).count

    limit = limit == 24 ? 25 : limit
    query.limit(limit).offset(offset).with_author

    set_cache :private, maxage: 5

    serv_json({
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

    return serv_text(nvinfo.bslug, 301) if nvinfo.bslug != bslug

    nvinfo.bump! if _cvuser.privi >= 0
    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvinfo.id)

    nvseeds = nvinfo.nvseeds.to_a.sort_by!(&.zseed)

    if nvseeds.empty? || nvseeds.first.sname != "$base"
      nvseeds.unshift(Nvseed.load!(nvinfo, "$base", force: true))
    end

    if (ubmemo.lr_sname.empty?) && (nvseed = nvseeds.first?)
      if chinfo = nvseed.chinfo(0)
        ubmemo.lr_sname = nvseed.sname
        ubmemo.lr_chidx = -1
        ubmemo.lc_uslug = chinfo.trans.uslug
      else
        ubmemo.lr_sname = "$base"
        ubmemo.lc_uslug = "thieu-chuong"
      end
    end

    set_cache :private, maxage: 30

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

  def extra
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
    raise Unauthorized.new("Cần quyền hạn tối thiểu là 3") if _cvuser.privi < 3
    form = NvinfoForm.new(params)

    if nvinfo = form.save(_cvuser.uname)
      serv_json({bslug: nvinfo.bslug})
    else
      serv_text(form.errors, 400)
    end
  end

  def delete
    return halt!(403, "Quyền hạn không đủ!") if _cvuser.privi < 4
    unless nvinfo = Nvinfo.load!(params["bslug"])
      return halt!(404, "Quyển sách không tồn tại!")
    end

    nvinfo.delete
    Ubmemo.query.where(nvinfo_id: nvinfo.id).to_delete.execute
    send_json({message: "ok"})
  end
end
