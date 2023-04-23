require "../_ctrl_base"

class CV::VilistCtrl < CV::BaseCtrl
  base "/_db/lists"

  @[AC::Route::GET("/")]
  def index(
    sort : String? = nil, type : String? = nil,
    user : String? = nil, book : Int64? = nil,
    qs : String? = nil
  )
    pg_no, limit, offset = _paginate(min: 1, max: 24)

    query = Vilist.query.sort_by(sort)

    query.where("klass = ?", type) if type
    query.where("viuser_id = (select id from viusers where uname = ?)", user) if user
    query.where("id in (select vilist_id from vicrits where nvinfo_id = ?)", book) if book

    query.where("tslug LIKE '%#{TextUtil.slugify(qs)}%'") if qs

    total = query.dup.limit(limit * 3 + offset).offset(0).count
    lists = query.limit(limit).offset(offset).to_a
    users = Viuser.preload(lists.map(&.viuser_id))

    render json: {
      lists: VilistView.as_list(lists, mode: :full),
      users: ViuserView.as_hash(users),
      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }
  end

  private def load_list(id : Int32)
    Vilist.find({id: id}) || raise NotFound.new("Thư đơn không tồn tại!")
  end

  @[AC::Route::GET("/:list_id")]
  def show(list_id : Int32,
           sort : String = "utime",
           smin : Int32 = 0, smax : Int32 = 6,
           lb : String? = nil)
    vilist = load_list(list_id)
    viuser = Viuser.load!(vilist.viuser_id)
    memoir = Memoir.load(_vu_id, :vilist, vilist.id)

    pg_no, limit, offset = _paginate(max: 20)
    crits = Vicrit.sort_by(sort)

    crits.where("vilist_id = ?", list_id)
    crits.where("stars >= ?", smin) if smin > 1
    crits.where("stars <= ?", smax) if smax < 5

    crits.limit(limit).offset(offset).to_a
    memos = Memoir.glob(_vu_id, :vicrit, crits.map(&.id.to_i))
    books = Wninfo.preload(crits.map(&.nvinfo_id))

    render json: {
      list: VilistView.new(vilist, mode: :full),
      user: ViuserView.new(viuser, full: false),
      memo: MemoirView.new(memoir),

      books: {
        crits: VicritView.as_list(crits, false),
        books: WninfoView.as_hash(books),
        memos: MemoirView.as_hash(memos),

        pgidx: pg_no,
        pgmax: _pgidx(vilist.book_count, limit),
      },
    }
  end

  @[AC::Route::GET("/form")]
  def upsert_form(id vl_id : Int32 = 0)
    guard_privi 0, "thêm/sửa thư đơn"

    lists = Vilist.query.where("viuser_id = ?", _vu_id).to_a

    vlist = lists.find(&.id.== vl_id)
    lists.reject!(&.id.== vl_id) if vlist

    render json: {
      ctime: vlist.try(&.created_at.to_unix) || 0,
      lform: init_form(vlist),
      lists: VilistView.as_list(lists, mode: :full),
    }
  end

  private def init_form(list : Nil)
    {id: 0, title: "[#{_uname}] Vô đề", dtext: "Tổng hợp truyện của tôi", klass: "both"}
  end

  private def init_form(list : Vilist)
    {id: list.id, title: list.title, dtext: list.dtext, klass: list.klass}
  end

  struct ListForm
    include JSON::Serializable

    getter title : String
    getter dtext : String
    getter klass : String

    def after_initialize
      @title = @title.strip
      @dtext = @dtext.strip

      @klass = "both" unless @klass.in?("male", "female")
    end
  end

  @[AC::Route::POST("/", body: form)]
  def create(form : ListForm)
    guard_privi 0, "tạo thư đơn"

    vilist = Vilist.new({viuser_id: _vu_id})
    vilist.patch!(form.title, form.dtext, form.klass)

    render json: VilistView.new(vilist, mode: :full)
  end

  @[AC::Route::PATCH("/:list_id", body: form)]
  def update(list_id : Int32, form : ListForm)
    vilist = load_list(list_id)
    guard_owner vilist.viuser_id, 0, "sửa thư đơn"

    vilist.patch!(form.title, form.dtext, form.klass)

    render json: VilistView.new(vilist, mode: :full)
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
