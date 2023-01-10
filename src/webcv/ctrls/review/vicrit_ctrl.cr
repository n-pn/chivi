require "../_ctrl_base"

class CV::VicritCtrl < CV::BaseCtrl
  base "/api/crits"

  @[AC::Route::GET("/", converters: {lm: ConvertLimit, tags: ConvertArray})]
  def index(pg pgidx : Int32 = 1, lm limit : Int32 = 24,
            sort : String? = nil,
            user : Int32? = nil,
            book : Int32? = nil,
            tags : Array(String)? = nil)
    offset = CtrlUtil.offset(pgidx, limit)

    query = Vicrit.query.sort_by(params["sort"]?)
    query.where("viuser_id = ?", user) if user
    query.where("nvinfo_id = ?", user) if book
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

    {
      total: total,
      pgidx: pgidx,
      pgmax: (total - 1) // limit + 1,
      crits: crits.map { |x| VicritView.new(x, full: false) },
      users: users.map { |x| {x.id, ViuserView.new(x, false)} }.to_h,
      books: books.map { |x| {x.id, NvinfoView.new(x, false)} }.to_h,
      lists: lists.map { |x| {x.id, VilistView.new(x, :crit)} }.to_h,
    }
  end

  private def load_crit(id : Int64)
    Vicrit.find({id: id}) || raise NotFound.new("Bình luận không tồn tại!")
  end

  @[AC::Route::GET("/:crit_id")]
  def show(crit_id : Int64)
    vicrit = load_crit(crit_id)

    {
      crit: VicritView.new(vicrit, full: true),
      user: ViuserView.new(vicrit.viuser, false),
      book: NvinfoView.new(vicrit.nvinfo, false),
    }
  end

  @[AC::Route::GET("/:crit_id/edit")]
  def edit(crit_id : Int64)
    vicrit = load_crit(crit_id)

    {
      id:    vicrit.id,
      stars: vicrit.stars,
      input: vicrit.itext,
      btags: vicrit.btags.join(", "),
    }
  end

  record CritBody, input : String, stars : Int32, btags : Array(String) do
    include JSON::Serializable
  end

  @[AC::Route::POST("/", body: body)]
  def create(book : Int64, body : CritBody, list : Int32 = -_viuser.id)
    raise Unauthorized.new("Bạn không có quyền tạo bình luận") unless allowed?(-1)

    vicrit = Vicrit.new({viuser: _viuser, nvinfo_id: book_id, vilist_id: list_id})
    vicrit.patch!(body.input, body.stars, body.btags)

    VicritView.new(vicrit, full: true)
  rescue err : PG::Error
    case msg = err.message.not_nil!
    when .includes?("unique constraint")
      raise BadRequest.new "Bình luận cho bộ sách đã tồn tại!"
    else
      raise BadRequest.new msg
    end
  end

  @[AC::Route::PATCH("/:crit_id", body: body)]
  def update(crit_id : Int64, body : CritBody)
    vicrit = load_crit(crit_id)

    raise Unauthorized.new("Bạn không có quyền sửa bình luận") unless allowed?(vicrit.viuser_id)

    vicrit.changed_at = Time.utc
    vicrit.patch!(body.input, body.stars, body.btags)

    VicritView.new(vicrit, full: true)
  end

  @[AC::Route::DELETE("/:crit_id")]
  def delete(crit_id : Int64)
    vicrit = load_crit(crit_id)
    owner_id = vicrit.viuser_id
    raise Unauthorized.new("Bạn không có quyền xoá bình luận") unless allowed?(owner_id)
    vicrit.update!({_flag: _viuser.privi > 3 && _viuser.id != owner_id ? -3 : -2})

    {msg: "Chủ đề đã bị xoá"}
  end
end
