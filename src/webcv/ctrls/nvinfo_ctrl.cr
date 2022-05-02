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

  def detail
    unless nvinfo = Nvinfo.load!(params["bslug"])
      return halt!(404, "Quyển sách không tồn tại!")
    end

    bcover = nvinfo.cvseed.bcover
    bcover = nvinfo.scover if bcover.empty?

    serv_json({
      genres: nvinfo.vgenres,
      bintro: nvinfo.cvseed.bintro,
      bcover: bcover,
    })
  end

  def upsert
    return halt!(403, "Quyền hạn không đủ!") if _cvuser.privi < 3

    btitle_zh = TextUtil.fix_spaces(params["btitle_zh"]).strip
    author_zh = TextUtil.fix_spaces(params["author_zh"]).strip
    btitle_zh, author_zh = BookUtil.fix_names(btitle_zh, author_zh)

    author = Author.upsert!(author_zh)
    params["author_vi"]?.try do |author_vi|
      author_vi = TextUtil.fix_spaces(author_vi).strip
      next if author_vi.empty?

      BookUtil.vi_authors.append!("#{author_zh}  #{btitle_zh}", author_vi)
      author.tap(&.set_vname(author_vi)).save!
    end

    btitle = Btitle.upsert!(btitle_zh)
    params["btitle_vi"]?.try do |btitle_vi|
      btitle_vi = TextUtil.fix_spaces(btitle_vi).strip
      next if btitle_vi.empty?

      BookUtil.vi_btitles.append!("#{btitle_zh}  #{author_zh}", btitle_vi)
      btitle.tap(&.set_vname(btitle_vi)).save!
    end

    nvinfo = Nvinfo.upsert!(author, btitle, fix_names: true)
    nvseed = Nvseed.upsert!(nvinfo, "users", nvinfo.bhash)

    nvseed.btitle = btitle_zh
    nvseed.author = author_zh

    params["bintro"]?.try do |bintro|
      bintro = TextUtil.split_html(bintro, true)
      nvseed.set_bintro(bintro, force: true)
      nvinfo.set_bintro(bintro, force: true)
    end

    params["genres"]?.try do |genres|
      genres = GenreMap.vi_to_zh(genres.split(",").map(&.strip))
      nvseed.set_genres(genres, force: true)
      nvinfo.set_genres(genres, force: true)
    end

    params["bcover"]?.try do |bcover|
      bcover = TextUtil.fix_spaces(bcover).strip
      next unless bcover.starts_with?("http")

      nvseed.set_bcover(bcover, force: true)
      nvinfo.set_bcover(bcover, force: true)

      spawn do
        img_file = "_db/bcover/users/#{nvinfo.bhash}.jpg"
        webp_file = "priv/static/covers/#{nvinfo.bcover}"
        HttpUtil.save_image(bcover, img_file, webp_file)
      end
    end

    params["status"]?.try do |status|
      status = TextUtil.fix_spaces(status).strip.to_i
      nvseed.set_status(status, force: true)
      nvinfo.set_status(status, force: true)
    end

    nvinfo.save!
    nvseed.save!

    spawn log_upsert_action(params)
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
