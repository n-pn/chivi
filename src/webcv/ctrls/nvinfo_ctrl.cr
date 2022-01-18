require "./base_ctrl"

class CV::NvinfoCtrl < CV::BaseCtrl
  private def extract_params
    page = params.fetch_int("page", min: 1)
    take = params.fetch_int("take", min: 1, max: 25)
    {page, take, (page - 1) * take}
  end

  def index
    Log.info { params.to_h }
    pgidx, limit, offset = extract_params

    query =
      Nvinfo.query
        # .where("subdue_id > -1")
        .filter_btitle(params["btitle"]?)
        .filter_author(params["author"]?)
        .filter_zseed(params["sname"]?)
        .filter_genre(params["genre"]?)
        .filter_origin(params["origin"]?)
        .filter_cvuser(params["uname"]?, params["bmark"]?)

    total = query.dup.limit(offset + limit * 3).offset(0).count

    limit = limit == 24 ? 25 : limit
    query.sort_by(params.fetch_str("order", "access"))
    query.limit(limit).offset(offset).with_author

    response.headers.add("Cache-Control", "public, min-fresh=180")

    json_view({
      total: total,
      pgidx: pgidx,
      pgmax: (total - 1) // limit + 1,
      books: query.map { |x| NvinfoView.new(x, false) },
    })
  rescue err
    Log.error { err.message }
    halt! 500, err.message
  end

  def show : Nil
    unless nvinfo = Nvinfo.find({bslug: params["bslug"]})
      return halt!(404, "Quyển sách không tồn tại!")
    end

    nvinfo.bump! if u_privi >= 0
    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvinfo.id)

    zhbooks = nvinfo.zhbooks.to_a.sort_by(&.zseed)
    if zhbooks.empty? || zhbooks.first.zseed != 0
      zhbooks.unshift(Zhbook.load!(nvinfo, 0))
    else
      base_zhbook = zhbooks[0]
      base_zhbook.copy_newers!(zhbooks[1..]) if base_zhbook.staled?
    end

    if (ubmemo.lr_sname.empty?) && (zhbook = zhbooks.first?)
      if chinfo = zhbook.chinfo(0)
        ubmemo.lr_sname = zhbook.sname
        ubmemo.lr_chidx = -1
        ubmemo.lc_uslug = chinfo.uslug
      else
        ubmemo.lr_sname = "chivi"
        ubmemo.lc_uslug = "thieu-chuong"
      end
    end

    response.headers.add("Cache-Control", "min-fresh=30")

    json_view do |jb|
      jb.object {
        jb.field "nvinfo" { NvinfoView.new(nvinfo, true).to_json(jb) }
        jb.field "ubmemo" { UbmemoView.render(jb, ubmemo) }

        jb.field "chseed" do
          jb.array do
            zhbooks.each do |zhbook|
              jb.object {
                jb.field "sname", zhbook.sname
                jb.field "snvid", zhbook.snvid
                # jb.field "wlink", zhbook.wlink
                jb.field "utime", zhbook.utime
                jb.field "chaps", zhbook.chap_count
                jb.field "_type", zhbook._type
              }
            end
          end
        end
      }
    end
  rescue err
    Log.error { err.message.colorize.red }
    halt! 500, "Có lỗi từ hệ thống"
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

    json_view({
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
  rescue err
    Log.error { err.inspect_with_backtrace }
    halt! 500, "Có lỗi từ hệ thống"
  end

  def upsert
    return halt!(403, "Quyền hạn không đủ!") if _cvuser.privi < 3

    btitle_zname, author_zname = NvUtil.fix_names(params["btitle"].strip, params["author"].strip)
    author = Author.upsert!(author_zname)
    nvinfo = Nvinfo.upsert!(author, btitle_zname)

    params["bintro"]?.try { |x| nvinfo.set_zintro(TextUtils.split_text(x), true) }
    params["genres"]?.try { |x| nvinfo.set_zgenre(x.split(' ').map(&.strip), true) }

    params["bcover"]?.try { |x| nvinfo.set_bcover(x, force: true) }
    params["status"]?.try { |x| nvinfo.set_status(x.to_i, force: true) }

    nvinfo.save!

    log_upsert_action(params)
    json_view({bslug: nvinfo.bslug})
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
