require "../_ctrl_base"

class CV::VicritCtrl < CV::BaseCtrl
  base "/_db/crits"

  @[AC::Route::GET("/", converters: {lb: ConvertArray})]
  def index(
    sort : String = "utime", smin : Int32 = 1, smax : Int32 = 5,
    user : String? = nil, book : Int32? = nil, list : Int32? = nil,
    lb tags : Array(String)? = nil
  )
    pg_no, limit, offset = _paginate(min: 1, max: 24)

    query = Vicrit.query.sort_by(sort)

    if user && (user_data = Viuser.find({uname: user}))
      query.where("viuser_id = ?", user_data.id)
    end

    query.where("nvinfo_id = ?", book) if book
    query.where("vilist_id = ?", list) if list

    query.where("stars >= ?", smin) if smin > 1
    query.where("stars <= ?", smax) if smax < 5

    query.where("btags @> ?", tags) if tags

    total = query.dup.limit(limit * 3 + offset).offset(0).count
    crits = query.limit(limit).offset(offset).to_a

    if crits.empty?
      users = [] of Viuser
      books = [] of Wninfo
      lists = [] of Vilist
    else
      users = Viuser.query.where("id in (#{crits.join(",", &.viuser_id)})")
      books = Wninfo.query.where("id in (#{crits.join(",", &.nvinfo_id)})")
      lists = Vilist.query.where("id in (#{crits.join(",", &.vilist_id)})")
    end

    render json: {
      crits: crits.map { |x| VicritView.new(x, full: false) },
      users: users.map { |x| {x.id, ViuserView.new(x, false)} }.to_h,
      books: books.map { |x| {x.id, WninfoView.new(x, false)} }.to_h,
      lists: lists.map { |x| {x.id, VilistView.new(x, :crit)} }.to_h,

      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
      total: total,
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

    render json: {
      crit: VicritView.new(vicrit, full: true),
      book: WninfoView.new(nvinfo, false),
      user: ViuserView.new(viuser, false),
      list: VilistView.new(vilist, mode: :crit),
    }
  end

  @[AC::Route::GET("/:crit_id/edit")]
  def edit_form(crit_id : Int32)
    vicrit = load_crit(crit_id)
    guard_owner vicrit.viuser_id, 0, "sửa đánh giá"

    render json: {
      id:    vicrit.id,
      bl_id: vicrit.vilist_id,
      stars: vicrit.stars,
      input: vicrit.itext,
      btags: vicrit.btags.join(", "),
    }
  end

  struct CritForm
    include JSON::Serializable

    getter wn_id : Int32
    getter bl_id : Int32?

    getter input : String
    getter stars : Int32 = 3
    getter btags : Array(String)

    def after_initialize
      @input = @input.strip
      @btags.map!(&.strip).reject!(&.empty?).uniq!

      @stars = 3 unless @stars.in?(1..5)
      @bl_id = nil if @bl_id == 0
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

    vicrit.patch!(form.input, form.stars, form.btags)

    render json: VicritView.new(vicrit, full: true)
  rescue err : PG::Error
    case msg = err.message || "Không rõ lỗi!"
    when .includes?("unique constraint")
      raise BadRequest.new "Bình luận cho bộ sách đã tồn tại!"
    else
      raise BadRequest.new msg
    end
  end

  @[AC::Route::PATCH("/:crit_id", body: body)]
  def update(crit_id : Int32, body : CritForm)
    vicrit = load_crit(crit_id)

    owner_id = vicrit.viuser_id
    guard_owner owner_id, 0, "sửa đánh giá"

    vicrit.changed_at = Time.utc
    vicrit.patch!(body.input, body.stars, body.btags)

    render json: VicritView.new(vicrit, full: true)
  end

  @[AC::Route::DELETE("/:crit_id")]
  def delete(crit_id : Int32)
    vicrit = load_crit(crit_id)

    owner_id = vicrit.viuser_id
    guard_owner owner_id, 0, "xoá đánh giá"

    is_admin = _privi > 3 && _vu_id != owner_id
    vicrit.update!({_flag: is_admin ? -3 : -2})

    render json: {msg: "đánh giá đã bị xoá"}
  end
end
