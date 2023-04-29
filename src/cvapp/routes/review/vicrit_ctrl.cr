require "../_ctrl_base"

class CV::VicritCtrl < CV::BaseCtrl
  base "/_db/crits"

  @[AC::Route::GET("/")]
  def index(sort : String = "utime",
            smin : Int32 = 1, smax : Int32 = 5,
            from : String = "vi", user : String? = nil,
            book : Int32? = nil, list : Int32? = nil,
            vtag : String? = nil)
    pg_no, limit, offset = _paginate(min: 1, max: 24)

    query = Vicrit.query.sort_by(sort)

    query.where("viuser_id = ?", _vu_id) if from == "me"
    query.where("viuser_id = (select id from viusers where uname = ?)", user) if user

    query.where("nvinfo_id = ?", book) if book
    query.where("vilist_id = ?", list) if list

    query.where("stars >= ?", smin) if smin > 1
    query.where("stars <= ?", smax) if smax < 5

    query.where("? = any(btags)", vtag) if vtag

    total = query.dup.limit((pg_no &+ 2) &* limit).offset(0).count
    crits = query.limit(limit).offset(offset).to_a

    users = Viuser.preload(crits.map(&.viuser_id))
    books = Wninfo.preload(crits.map(&.nvinfo_id))
    lists = Vilist.preload(crits.map(&.vilist_id))

    memos = Memoir.glob(_vu_id, :vicrit, crits.map(&.id.to_i))

    render json: {
      crits: VicritView.as_list(crits, full: false),
      users: ViuserView.as_hash(users),
      memos: MemoirView.as_hash(memos),

      books: WninfoView.as_hash(books),
      lists: VilistView.as_hash(lists),

      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }
  end

  private def load_crit(id : Int64)
    Vicrit.find({id: id}) || raise NotFound.new("Bình luận không tồn tại!")
  end

  @[AC::Route::GET("/:crit_id")]
  def show(crit_id : Int32)
    vicrit = load_crit(crit_id)
    nvinfo = Wninfo.load!(vicrit.nvinfo_id)

    viuser = Viuser.load!(vicrit.viuser_id)
    vilist = Vilist.load!(vicrit.vilist_id)

    memoir = Memoir.load(_vu_id, :vicrit, vicrit.id)

    render json: {
      crit: VicritView.new(vicrit, full: true),
      book: WninfoView.new(nvinfo, false),
      user: ViuserView.new(viuser, false),
      list: VilistView.new(vilist, mode: :crit),
      memo: MemoirView.new(memoir),
    }
  end

  @[AC::Route::GET("/form")]
  def upsert_form(wn wn_id : Int32 = 0, id vc_id : Int32 = 0)
    guard_privi 0, "thêm/sửa đánh giá"

    wninfo = Wninfo.load!(wn_id)

    lists = Vilist.query.where("viuser_id = ?", _vu_id).to_a
    crits = Vicrit.query.where("nvinfo_id = ?", wn_id).where("viuser_id = ?", _vu_id).to_a

    vcrit = crits.find(&.id.== vc_id)
    crits.reject!(&.id.== vc_id) if vcrit
    memos = Memoir.glob(_vu_id, :vicrit, crits.map(&.id.to_i))

    render json: {
      bname: wninfo.btitle.vname,
      bslug: "#{wn_id}-#{wninfo.bslug}",

      ctime: vcrit.try(&.created_at.to_unix) || 0,
      cform: init_form(vcrit, wn_id),

      lists: VilistView.as_list(lists, mode: :crit),
      crits: VicritView.as_list(crits),
      memos: MemoirView.as_hash(memos),
    }
  end

  private def init_form(crit : Nil, wn_id : Int32)
    {id: 0, wn_id: wn_id, bl_id: -_vu_id, stars: 3, input: "", btags: ""}
  end

  private def init_form(crit : Vicrit, wn_id : Int32)
    {
      id: crit.id, wn_id: wn_id, bl_id: crit.vilist_id,
      stars: crit.stars, input: crit.itext, btags: crit.btags.join(", "),
    }
  end

  struct CritForm
    include JSON::Serializable

    getter wn_id : Int32
    getter bl_id : Int32?

    getter input : String
    getter stars : Int32 = 3
    getter btags : String

    def after_initialize
      @input = @input.strip
      @stars = 3 unless @stars.in?(1..5)
      @bl_id = nil if @bl_id == 0
    end

    def tag_list
      @btags.split(',').map!(&.strip).reject!(&.empty?).uniq!(&.downcase)
    end
  end

  @[AC::Route::POST("/", body: form)]
  def create(form : CritForm)
    guard_privi 0, "tạo đánh giá"

    vicrit = Vicrit.new({
      viuser_id: _viuser.id,
      nvinfo_id: form.wn_id,
      vilist_id: form.bl_id || -_vu_id,
    })

    vicrit.patch!(form.input, form.stars, form.tag_list)
    spawn Vilist.inc_counter(vicrit.vilist_id, "book_count")

    render json: VicritView.new(vicrit, full: true)
  rescue err
    case msg = err.message || "Không rõ lỗi!"
    when .includes?("unique constraint")
      render :bad_request, text: "Thư đơn bạn chọn đã có đánh giá bộ truyện!"
    else
      render :bad_request, text: msg
    end
  end

  @[AC::Route::PATCH("/:crit_id", body: form)]
  def update(crit_id : Int32, form : CritForm)
    vicrit = load_crit(crit_id)

    owner_id = vicrit.viuser_id
    guard_owner owner_id, 0, "sửa đánh giá"

    old_list_id = vicrit.vilist_id
    new_list_id = form.bl_id || old_list_id

    if old_list_id != new_list_id
      spawn do
        Vilist.dec_counter(old_list_id, "book_count")
        Vilist.inc_counter(new_list_id, "book_count")
      end
    end

    vicrit.vilist_id = new_list_id
    vicrit.changed_at = Time.utc
    vicrit.patch!(form.input, form.stars, form.tag_list)

    render json: VicritView.new(vicrit, full: true)
  end

  @[AC::Route::DELETE("/:crit_id")]
  def delete(crit_id : Int32)
    vicrit = load_crit(crit_id)

    spawn Vilist.dec_counter(vicrit.vilist_id, "book_count")

    owner_id = vicrit.viuser_id
    guard_owner owner_id, 0, "xoá đánh giá"

    is_admin = _privi > 3 && _vu_id != owner_id
    vicrit.update!({_flag: is_admin ? -3 : -2})

    render json: {msg: "đánh giá đã bị xoá"}
  end
end
