require "../_ctrl_base"
require "./wninfo_form"
require "../../../mt_v1/data/v1_dict"

class CV::WnovelCtrl < CV::BaseCtrl
  base "/_db/books"

  @[AC::Route::GET("/")]
  def index(
    order : String = "access",
    btitle : String? = nil, author : String? = nil,
    chroot : String? = nil, origin : String? = nil,
    genres : String? = nil, tagged : String? = nil,
    voters : Int32? = nil, rating : Int32? = nil,
    uname : String? = nil, bmark : String? = nil,
    status : Int32? = nil
  )
    pg_no, limit, offset = _paginate(max: 100)

    query = Nvinfo.query.sort_by(order)

    query.filter_btitle(btitle) if btitle
    query.filter_author(author) if author
    query.filter_wnseed(chroot) if chroot
    query.filter_origin(origin) if origin

    query.filter_genres(genres)
    query.filter_tagged(tagged)

    query.where("status = ?", status - 1) if status
    query.where("voters >= ?", voters) if voters
    query.where("rating >= ?", rating) if rating
    query.filter_viuser(uname, bmark) if uname && bmark

    total = query.dup.limit(offset + limit * 3).offset(0).count
    query.limit(limit == 24 ? 25 : limit).offset(offset).with_author

    render json: {
      books: WnovelView.as_list(query),
      total: total, pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }
  end

  @[AC::Route::GET("/find/:bslug")]
  def find(bslug : String) : Nil
    frags = TextUtil.slugify(bslug).split('-')
    query = "bhash like '#{frags[0]}%' or bhash like '#{frags[-1]}%'"

    if wnovel = Nvinfo.find(query)
      found = "#{wnovel.id}-#{wnovel.bslug}"
    end

    render json: {found: found}
  end

  #############
  private def get_wnovel(wn_id : Int64)
    Nvinfo.find({id: wn_id}) || raise NotFound.new("Quyển sách không tồn tại!")
  end

  @[AC::Route::GET("/:wn_id/show")]
  def show(wn_id : Int64) : Nil
    nvinfo = get_wnovel(wn_id)
    spawn nvinfo.bump! if _privi >= 0
    render json: WnovelView.new(nvinfo, true)
  end

  # show related data for book front page
  @[AC::Route::GET("/:wn_id/front")]
  def front(wn_id : Int64)
    nvinfo = get_wnovel(wn_id)

    # spawn Nvstat.inc_info_view(nvinfo.id)

    books = Nvinfo.query
      .where("author_id = ?", nvinfo.author_id)
      .where("id <> ?", nvinfo.id)
      .order_by(weight: :desc)
      .limit(6)

    users = Ubmemo.query
      .where("nvinfo_id = ?", nvinfo.id)
      .where("status > 0")
      .order_by(utime: :desc)
      .with_viuser

    render json: {
      books: books.map { |x| WnovelView.new(x, false) },
      users: users.map { |x| {u_dname: x.viuser.uname, u_privi: x.viuser.privi, _status: x.status_s} },
    }
  end

  @[AC::Route::GET("/:wn_id/edit_form")]
  def edit_form(wn_id : Int64)
    nvinfo = get_wnovel(wn_id)

    render json: {
      ztitle: nvinfo.btitle.zname,
      vtitle: nvinfo.btitle.vname,

      zauthor: nvinfo.author.zname,
      vauthor: nvinfo.author.vname,

      zintro: nvinfo.zintro,
      vintro: nvinfo.bintro,

      genres: nvinfo.vgenres,
      bcover: nvinfo.scover,
      status: nvinfo.status,
    }
  end

  @[AC::Route::POST("/", body: :form)]
  def upsert(form : WnovelForm)
    guard_privi 2, "thêm truyện/sửa nội dung truyện"

    nvinfo = form.save!(_uname, _privi)
    WnLink.upsert!(nvinfo.id.to_i, form.wn_links)

    Nvinfo.cache!(nvinfo)

    spawn add_book_dict(nvinfo.id, nvinfo.bslug, nvinfo.vname)
    spawn CtrlUtil.log_user_action("nvinfo-upsert", params.to_h, _viuser.uname)
    spawn upload_bcover_to_r2!(nvinfo.scover, nvinfo.bcover)

    render json: {id: nvinfo.id, bslug: nvinfo.bslug}
  rescue ex
    Log.error(exception: ex) { ex.message.colorize.red }
    render :bad_request, text: ex.message
  end

  private def upload_bcover_to_r2!(source_url : String, cover_name : String)
    `bin/bcover_cli single -i "#{source_url}" -n #{cover_name}`
  end

  private def add_book_dict(wn_id : Int64, bslug : String, bname : String)
    dname = "#{wn_id}-#{bslug}"
    url = "#{CV_ENV.m1_host}/_m1/dicts?wn_id=#{wn_id}&dname=#{dname}&bname=#{bname}"
    HTTP::Client.put(url)
    # TODO: call mt_v1 api instead
  end

  @[AC::Route::DELETE("/:wn_id")]
  def delete(wn_id : Int64)
    guard_privi 4, "xóa bộ truyện"
    nvinfo = get_wnovel(wn_id)

    nvinfo.delete
    # FIXME: using database constraint instead
    Ubmemo.query.where(nvinfo_id: nvinfo.id).to_delete.execute

    render json: {msg: "ok"}
  end
end
