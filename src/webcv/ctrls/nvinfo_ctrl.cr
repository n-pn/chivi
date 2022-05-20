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

    spawn do
      nvinfo.bump! if _cvuser.privi >= 0
    end

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
        ubmemo.lr_sname = "union"
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

  def detail
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
    if _cvuser.privi < 3
      raise Unauthorized.new("Cần quyền hạn tối thiểu là 3")
    end

    btitle_zh = TextUtil.fix_spaces(params["btitle_zh"]).strip
    author_zh = TextUtil.fix_spaces(params["author_zh"]).strip
    btitle_zh, author_zh = BookUtil.fix_names(btitle_zh, author_zh)

    author = Author.upsert!(author_zh)
    params["author_vi"]?.try do |author_vi|
      author_vi = TextUtil.fix_spaces(author_vi).strip
      unless author_vi.empty?
        BookUtil.vi_authors.append!(author_zh, author_vi)
        author.tap(&.set_vname(author_vi)).save!
      end
    end

    btitle = Btitle.upsert!(btitle_zh)
    params["btitle_vi"]?.try do |btitle_vi|
      btitle_vi = TextUtil.fix_spaces(btitle_vi).strip
      unless btitle_vi.empty?
        BookUtil.vi_btitles.append!(btitle_zh, btitle_vi)
        btitle.tap(&.set_vname(btitle_vi)).save!
      end
    end

    nvinfo = Nvinfo.upsert!(author, btitle, fix_names: true)
    nvseed = Nvseed.upsert!(nvinfo, "users", nvinfo.bhash)

    nvseed.nvinfo = nvinfo
    nvseed.btitle = btitle_zh
    nvseed.author = author_zh

    params["bintro"]?.try do |bintro|
      bintro = TextUtil.split_html(bintro, true)
      nvseed.set_bintro(bintro, mode: 2)
    end

    params["genres"]?.try do |genres|
      vgenres = genres.split(",").map(&.strip)
      nvinfo.igenres = GenreMap.map_int(vgenres)

      zgenres = GenreMap.vi_to_zh(vgenres)
      nvseed.set_genres(zgenres, mode: 1)
    end

    params["bcover"]?.try do |bcover|
      bcover = TextUtil.fix_spaces(bcover).strip
      nvseed.set_bcover(bcover, mode: 2)
    end

    params["status"]?.try do |status|
      status = TextUtil.fix_spaces(status).strip.to_i
      nvseed.set_status(status, mode: 2)
    end

    nvinfo.save!
    nvseed.save!
    Nvinfo.cache!(nvinfo)

    spawn do
      `bin/bcover_cli "#{nvinfo.scover}" #{nvinfo.bcover} users`
      body = params.to_unsafe_h.tap(&.delete("_json"))
      CtrlUtil.log_user_action("nvinfo-upsert", body, _cvuser.uname)
    end

    serv_json({bslug: nvinfo.bslug})
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
