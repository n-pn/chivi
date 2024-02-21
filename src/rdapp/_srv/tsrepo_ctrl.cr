require "./_ctrl_base"

class RD::TsrepoCtrl < AC::Base
  base "/_rd/tsrepos"

  @[AC::Route::GET("/")]
  def index(stype : String = "",
            rtype : String = "",
            order : String = "mtime",
            state : Int32 = -1,
            stars : Int32 = -1,
            wn_id : Int32 = 0)
    pg_no, limit, offset = self._paginate(min: 1, max: 50)
    repos = Tsrepo.get_all(
      vu_id: self._vu_id, state: state, stars: stars,
      stype: stype, wn_id: wn_id, order: order,
      limit: limit == 24 ? 25 : limit, offset: offset)

    if repos.size < limit
      total = offset &+ repos.size
    else
      total = offset &+ Tsrepo.get_all(
        vu_id: self._vu_id, state: state, stars: stars,
        stype: stype, wn_id: wn_id, order: order,
        limit: limit * 3, offset: offset).size
    end

    memos = Rdmemo.fetch_all(self._vu_id, repos.map(&.id.not_nil!)).to_h { |x| {x.rd_id, x} }
    json = {memos: memos, repos: repos, pgidx: pg_no, pgmax: _pgidx(total, limit)}
    render json: json
  end

  @[AC::Route::GET("/for_wn")]
  def for_wn(wn_id : Int32)
    query = Tsrepo.schema.select_stmt do |sql|
      sql << " where wn_id = $1"
      sql << " order by stype asc, mtime desc"
    end

    items = PGDB.query_all(query, wn_id, as: Tsrepo)
    render json: items
  end

  @[AC::Route::GET("/:sname/:sn_id")]
  def show(sname : String, sn_id : Int32)
    xstem = get_xstem(sname, sn_id)

    crepo = xstem.crepo
    crepo.fix_pdict! if crepo.pdict.empty?

    rmemo = Rdmemo.load!(vu_id: self._vu_id, sname: sname.sub(/wn|up|rm/, ""), sn_id: sn_id)

    render json: {
      xstem: xstem,
      crepo: crepo,
      rmemo: rmemo,
    }
  end

  @[AC::Route::GET("/:sname/:sn_id/reload")]
  def reload(sname : String, sn_id : Int32, cmode : Int32 = 0)
    crepo = Tsrepo.load!("#{sname}/#{sn_id}")
    crepo.fix_pdict! if crepo.pdict.empty?

    regen = cmode > 0 ? crepo.update_from_link!(cmode: cmode) : false
    crepo.update_vinfos!

    render json: {
      chmax: crepo.chmax,
      mtime: crepo.mtime,
      regen: regen,
    }
  end

  struct TsrepoForm
    include JSON::Serializable

    getter slink : String? = nil
    getter pdict : String? = nil
    getter multp : Int16? = nil
  end

  SLINK_PLOCK = {1, 1, 1}
  PDICT_PLOCK = {2, 1, 2}
  MULTP_PLOCK = {3, 1, 3}

  @[AC::Route::PATCH("/:sname/:sn_id", body: cform)]
  def config(sname : String, sn_id : Int32, cform : TsrepoForm)
    crepo = Tsrepo.load!("#{sname}/#{sn_id}")

    owner, plock = crepo.edit_privi(self._vu_id)
    guard_owner owner, plock, "sửa thiết đặt nguồn chương"

    if slink = cform.slink
      guard_privi SLINK_PLOCK[crepo.stype], "sửa nguồn liên kết ngoài"
      crepo.rm_slink = slink
    end

    if pdict = cform.pdict
      guard_privi PDICT_PLOCK[crepo.stype], "chọn từ điển chính thức"
      crepo.pdict = pdict
    end

    if multp = cform.multp
      guard_privi MULTP_PLOCK[crepo.stype], "sửa hệ số nhân truyện"
      crepo.multp = multp
    end

    crepo.upsert!
    render json: crepo
  end
end
