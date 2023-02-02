require "../_ctrl_base"

class CV::VicritCtrl < CV::BaseCtrl
  base "/_db/crits"

  @[AC::Route::GET("/", converters: {lm: ConvertLimit, tags: ConvertArray})]
  def index(
    sort : String? = nil,
    user : Int32? = nil,
    book : Int32? = nil,
    tags : Array(String)? = nil
  )
    pg_no, limit, offset = _paginate(min: 1, max: 24)

    query = Vicrit.query.sort_by(sort)
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
  def edit(crit_id : Int64)
    vicrit = load_crit(crit_id)

    render json: {
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
  def create(book_id : Int64, body : CritBody, list_id : Int32 = -_viuser.id)
    unless _viuser.can?(:create_post)
      raise Unauthorized.new("Bạn không có quyền tạo bình luận")
    end

    vicrit = Vicrit.new({viuser_id: _viuser.id, nvinfo_id: book_id, vilist_id: list_id})
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

    unless _viuser.can?(vicrit.viuser_id, :update_post)
      raise Unauthorized.new("Bạn không có quyền sửa bình luận")
    end

    vicrit.changed_at = Time.utc
    vicrit.patch!(body.input, body.stars, body.btags)

    render json: VicritView.new(vicrit, full: true)
  end

  @[AC::Route::DELETE("/:crit_id")]
  def delete(crit_id : Int64)
    vicrit = load_crit(crit_id)
    owner_id = vicrit.viuser_id

    unless _viuser.can?(owner_id, :update_post)
      raise Unauthorized.new("Bạn không có quyền xoá bình luận")
    end

    vicrit.update!({_flag: _viuser.privi > 3 && _viuser.id != owner_id ? -3 : -2})

    render json: {msg: "Chủ đề đã bị xoá"}
  end
end
