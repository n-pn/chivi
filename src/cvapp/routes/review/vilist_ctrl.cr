require "../_ctrl_base"

class CV::VilistCtrl < CV::BaseCtrl
  base "/_db/lists"

  @[AC::Route::GET("/")]
  def index(
    sort order : String = "mixed",
    user vuser : String? = nil,
    type klass : String? = nil,
    book wbook : Int32? = nil,
    qs query : String? = nil
  )
    pg_no, limit, offset = _paginate(min: 1, max: 24)

    klass = nil unless klass.in?("male", "female")
    query = TextUtil.slugify(query) if query

    total = VilistCard.count_all(vuser, klass, wbook, query)
    lists = VilistCard.fetch_all(_vu_id, order, vuser, klass, wbook, query, limit, offset)

    render json: {
      lists: lists,
      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }
  end

  @[AC::Route::GET("/:list_id")]
  def show(list_id : Int32,
           sort : String = "utime",
           smin : Int32 = 0, smax : Int32 = 6,
           lb : String? = nil)
    spawn VilistCard.inc_counter(list_id, "view_count", 1)
    vlist = VilistCard.fetch_one(list_id, _vu_id)

    pg_no, limit, offset = _paginate(max: 20)
    crits = Vicrit.sort_by(sort)

    crits.where("vilist_id = ?", list_id)
    crits.where("stars >= ?", smin) if smin > 1
    crits.where("stars <= ?", smax) if smax < 5

    crits.limit(limit).offset(offset).to_a
    memos = Memoir.glob(_vu_id, :vicrit, crits.map(&.id.to_i))
    books = Wninfo.preload(crits.map(&.nvinfo_id))

    render json: {
      list: vlist,

      books: {
        crits: VicritView.as_list(crits, false),
        books: WninfoView.as_hash(books),
        memos: MemoirView.as_hash(memos),

        pgidx: pg_no,
        pgmax: _pgidx(vlist.book_count, limit),
      },
    }
  end

  @[AC::Route::GET("/form")]
  def upsert_form(id list_id : Int32 = 0)
    guard_privi 0, "thêm/sửa thư đơn"

    lists = VilistCard.all_by_user(_vu_id, _vu_id)

    vlist = lists.find(&.vl_id.== list_id)
    lists.reject!(&.vl_id.== list_id) if vlist

    render json: {
      ctime: vlist.try(&.ctime) || 0,
      lform: init_form(vlist),
      lists: lists,
    }
  end

  private def init_form(list : Nil)
    {
      id:    0,
      title: "[#{_uname}] Vô đề",
      klass: "",
      dtext: "Tổng hợp truyện của tôi",
    }
  end

  private def init_form(list : VilistCard)
    {
      id:    list.vl_id,
      title: list.title,
      klass: list.klass,
      dtext: VilistCard.get_dtext(list.vl_id),
    }
  end

  struct ListForm
    include JSON::Serializable

    getter title : String
    getter dtext : String
    getter klass : String

    def after_initialize
      @title = @title.strip
      @dtext = @dtext.strip

      @klass = "" unless @klass.in?("male", "female")
    end
  end

  @[AC::Route::POST("/", body: form)]
  def create(form : ListForm)
    guard_privi 0, "tạo thư đơn"

    vilist = Vilist.new({viuser_id: _vu_id})
    vilist.patch!(form.title, form.dtext, form.klass)

    render text: "#{vilist.id}-#{vilist.tslug}"
  end

  private def load_list(id : Int32)
    Vilist.find({id: id}) || raise NotFound.new("Thư đơn không tồn tại!")
  end

  @[AC::Route::PATCH("/:list_id", body: form)]
  def update(list_id : Int32, form : ListForm)
    vilist = load_list(list_id)
    guard_owner vilist.viuser_id, 0, "sửa thư đơn"

    vilist.patch!(form.title, form.dtext, form.klass)

    render text: "#{vilist.id}-#{vilist.tslug}"
  end

  @[AC::Route::DELETE("/:list_id")]
  def delete(list_id : Int32)
    vilist = load_list(list_id)

    guard_owner vilist.viuser_id, 0, "xoá thư đơn"

    if vilist.book_count > 0
      render :forbidden, text: "Bạn chỉ có thể xoá nếu thư đơn không có bộ sách nào"
    else
      PGDB.exec("delete from vilists where id = $1", list_id)
      render text: "thư đơn đã bị xoá"
    end
  end
end
