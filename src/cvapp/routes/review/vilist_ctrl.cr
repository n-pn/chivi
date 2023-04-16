require "../_ctrl_base"

class CV::VilistCtrl < CV::BaseCtrl
  base "/_db/lists"

  @[AC::Route::GET("/")]
  def index(sort : String? = nil, user : Int32? = nil, type : String? = nil)
    pg_no, limit, offset = _paginate(min: 1, max: 24)

    query = Vilist.query.sort_by(sort)
    query.where("_flag >= 0")

    if viuser = Viuser.find({uname: user})
      query.where("viuser_id = ?", viuser.id)
    end

    query.where("klass = ?", type) if type

    total = query.dup.limit(limit * 3 + offset).offset(0).count
    lists = query.limit(limit).offset(offset).to_a

    users = viuser ? [viuser] : Viuser.preload(lists.map(&.viuser_id))

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

    pg_no, limit, offset = _paginate(max: 20)
    crits = Vicrit.sort_by(sort)

    crits.where("vilist_id = ?", list_id)
    crits.where("stars >= ?", smin) if smin > 1
    crits.where("stars <= ?", smax) if smax < 5

    crits.limit(limit).offset(offset).to_a

    books = Wninfo.preload(crits.map(&.nvinfo_id))

    render json: {
      list: VilistView.new(vilist, mode: :full),
      user: ViuserView.new(viuser, full: false),

      books: {
        crits: VicritView.as_list(crits, false),
        books: WninfoView.as_hash(books),

        pgidx: pg_no,
        pgmax: _pgidx(vilist.book_count, limit),
      },
    }
  end

  @[AC::Route::GET("/:list_id/edit")]
  def edit_form(list_id : Int32)
    vilist = load_list(list_id)
    guard_owner vilist.viuser_id, 0, "sửa đánh giá"

    render json: {
      id:    vilist.id,
      title: vilist.title,
      intro: vilist.dtext,
      klass: vilist.klass,
    }
  end

  struct ListForm
    include JSON::Serializable

    getter title : String
    getter intro : String
    getter klass : String

    def after_initialize
      @title = @title.strip
      @intro = @intro.strip

      @klass = "both" unless @klass.in?("male", "female")
    end
  end

  @[AC::Route::POST("/", body: form)]
  def create(form : ListForm)
    guard_privi 0, "tạo thư đơn"

    vilist = Vilist.new({viuser_id: _vu_id})

    vilist.set_title form.title
    vilist.set_intro form.intro

    render json: VilistView.new(vilist, mode: :full)
  end

  @[AC::Route::PATCH("/:list_id", body: form)]
  def update(list_id : Int32, form : ListForm)
    vilist = load_list(list_id)
    guard_owner vilist.viuser_id, 0, "sửa thư đơn"

    vilist.set_title(form.title) unless list_id < 0
    vilist.set_intro(form.intro)

    render json: VilistView.new(vilist, mode: :full)
  end

  @[AC::Route::DELETE("/:list_id")]
  def delete(list_id : Int32)
    vilist = load_list(list_id)

    owner_id = vilist.viuser_id
    guard_owner owner_id, 0, "xoá thư đơn"

    is_admin = _privi > 3 && _vu_id != owner_id
    vilist.update!({_flag: is_admin ? -3 : -2})

    render json: {msg: "thư đơn đã bị xoá"}
  end
end
