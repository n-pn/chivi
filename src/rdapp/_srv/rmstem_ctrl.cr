require "./_ctrl_base"

class RD::RmstemCtrl < AC::Base
  base "/_rd/rmstems"

  @[AC::Route::GET("/")]
  def index(
    wn wn_id : Int32? = nil,
    sn sname : String? = nil,
    lb genre : String? = nil,
    st status : Int32? = nil,
    bt btitle : String? = nil,
    by author : String? = nil,
    _s order : String = "rtime",
    _m qmode : String = "index"
  )
    pg_no, limit, offset = _paginate(min: 25, max: 100)

    query, args = Rmstem.build_select_sql(
      btitle: btitle,
      author: author,
      status: status,
      wn_id: wn_id,
      sname: sname,
      genre: genre,
      liked: qmode == "liked" ? self._vu_id : nil,
      order: order,
    )
    args << limit << offset

    items = Rmstem.db.query_all(query, args: args, as: Rmstem)

    if items.size < limit
      total = items.size &+ offset
    else
      query = query.sub("select *", "select chap_count")
      args[-2] = limit &* 3
      total = Rmstem.db.query_all(query, args: args, as: Int32).size &+ offset
    end

    json = {
      items: items,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: json
  end

  # @[AC::Route::POST("/", body: form)]
  # def create(form : Rmstem)
  #   guard_privi 1, "tạo dự án cá nhân"

  #   form.id = nil
  #   form.sname = "@#{_uname}"
  #   form.viuser_id = _vu_id
  #   form.wninfo_id = nil if form.wninfo_id == 0

  #   saved = form.insert!
  #   saved.mkdirs!

  #   render json: saved
  # end

  # @[AC::Route::GET("/:sname/:sn_id")]
  # def show(sname : String, sn_id : String, crawl : Int32 = 0, regen : Bool = false)
  #   rstem = get_rstem(sname, sn_id)

  #   if regen
  #     rstem.fix_wn_id!
  #     rstem.translate!
  #   end

  #   rstem.update!(crawl, regen) if crawl > 0 || regen
  #   rmemo = Rdmemo.load!(vu_id: self._vu_id, sname: "rm#{sname}", sn_id: sn_id)

  #   render json: {
  #     rstem: rstem,
  #     crepo: rstem.crepo,
  #     rmemo: rmemo,
  #   }
  # end

  @[AC::Route::POST("/")]
  def upsert!(rlink : String)
    guard_privi 1, "thêm nguồn nhúng mới"

    rhost = Rmhost.from_link!(rlink)
    sn_id = rhost.extract_bid(rlink)
    bfile = rhost.book_file(sn_id)

    bhtml = rhost.load_page(rlink, bfile)

    rstem = Rmstem.from_html(bhtml, rhost.seedname, sn_id, force: true)
    raise BadRequest.new("Nguồn truyện không hợp lệ") unless rstem

    rstem.rlink = rlink
    rstem.rtime = File.info(bfile).modification_time.to_unix

    rstem.fix_wn_id!
    rstem.translate!

    rstem.upsert!

    render json: rstem
  rescue ex
    Log.error(exception: ex) { ex }
    render text: ex.message || "500"
  end
end
