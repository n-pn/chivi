require "../_ctrl_base"

class CV::VicritCtrl < CV::BaseCtrl
  base "/_db/crits"

  @[AC::Route::GET("/", converters: {tags: ConvertArray})]
  def index(
    sort : String? = nil,
    user : Int32? = nil,
    book : Int32? = nil,
    tags : Array(String)? = nil
  )
    pg_no, limit, offset = _paginate(min: 1, max: 24)

    query = Vicrit.query.sort_by(sort)
    query.where("viuser_id = ?", user) if user
    query.where("nvinfo_id = ?", book) if book
    query.where("btags = ?", tags) if tags

    total = query.dup.limit(limit * 3 + offset).offset(0).count
    crits = query.limit(limit).offset(offset).to_a

    if crits.empty?
      users = [] of Viuser
      books = [] of Nvinfo
      lists = [] of Vilist
    else
      users = Viuser.query.where("id in (#{crits.join(",", &.viuser_id)})")
      books = Nvinfo.query.where("id in (#{crits.join(",", &.nvinfo_id)})")
      lists = Vilist.query.where("id in (#{crits.join(",", &.vilist_id)})")
    end

    render json: {
      total: total,
      pgidx: pg_no,
      pgmax: (total - 1) // limit + 1,
      crits: crits.map { |x| VicritView.new(x, full: false) },
      users: users.map { |x| {x.id, ViuserView.new(x, false)} }.to_h,
      books: books.map { |x| {x.id, WnovelView.new(x, false)} }.to_h,
      lists: lists.map { |x| {x.id, VilistView.new(x, :crit)} }.to_h,
    }
  end

  private def load_crit(id : Int64)
    Vicrit.find({id: id}) || raise NotFound.new("Bình luận không tồn tại!")
  end

  @[AC::Route::GET("/:crit_id")]
  def show(crit_id : Int64)
    vicrit = load_crit(crit_id)

    render json: {
      crit: VicritView.new(vicrit, full: true),
      user: ViuserView.new(vicrit.viuser, false),
      book: WnovelView.new(vicrit.nvinfo, false),
    }
  end

  @[AC::Route::GET("/:crit_id/edit")]
  def edit_form(crit_id : Int64)
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
  def update(crit_id : Int64, body : CritForm)
    vicrit = load_crit(crit_id)
    guard_owner vicrit.viuser_id, 0, "sửa đánh giá"

    vicrit.changed_at = Time.utc
    vicrit.patch!(body.input, body.stars, body.btags)

    render json: VicritView.new(vicrit, full: true)
  end

  @[AC::Route::DELETE("/:crit_id")]
  def delete(crit_id : Int64)
    vicrit = load_crit(crit_id)
    owner_id = vicrit.viuser_id
    guard_owner owner_id, 0, "xoá đánh giá"

    vicrit.update!({_flag: _viuser.privi > 3 && _viuser.id != owner_id ? -3 : -2})

    render json: {msg: "Chủ đề đã bị xoá"}
  end
end
