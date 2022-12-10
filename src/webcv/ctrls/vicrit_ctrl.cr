require "./shared/ctrl_base"

class CV::VicritCtrl < CV::BaseCtrl
  def index
    pgidx, limit, offset = params.page_info(max: 24)

    query = Vicrit.query.sort_by(params["sort"]?)
    params["user"]?.try { |x| query.where("viuser_id = ?", x.to_i) }
    params["book"]?.try { |x| query.where("nvinfo_id = ?", x.to_i) }
    params["tags"]?.try { |x| query.where("btags @> ?", x.split(",")) }

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

    serv_json({
      total: total,
      pgidx: pgidx,
      pgmax: (total - 1) // limit + 1,
      crits: crits.map { |x| VicritView.new(x, full: false) },
      users: users.map { |x| {x.id, ViuserView.new(x, false)} }.to_h,
      books: books.map { |x| {x.id, NvinfoView.new(x, false)} }.to_h,
      lists: lists.map { |x| {x.id, VilistView.new(x, :crit)} }.to_h,
    })
  end

  private def load_crit(id = params["crit"].to_i64)
    Vicrit.find({id: params["crit"].to_i64}) || raise NotFound.new("Bình luận không tồn tại!")
  end

  def show
    vicrit = load_crit

    serv_json({
      crit: VicritView.new(vicrit, full: true),
      user: ViuserView.new(vicrit.viuser, false),
      book: NvinfoView.new(vicrit.nvinfo, false),
    })
  end

  def create
    raise Unauthorized.new("Bạn không có quyền tạo bình luận") unless allowed?(-1)

    book_id = params["book"].to_i64
    list_id = params["list"]?.try(&.to_i) || -_viuser.id

    vicrit = Vicrit.new({viuser: _viuser, nvinfo_id: book_id, vilist_id: list_id})

    begin
      vicrit.patch!(params["input"], params["stars"], params["btags"])

      serv_json(VicritView.new(vicrit, full: true))
    rescue err : PG::Error
      case msg = err.message.not_nil!
      when .includes?("unique constraint")
        raise BadRequest.new "Bình luận cho bộ sách đã tồn tại!"
      else
        raise BadRequest.new msg
      end
    end
  end

  def edit
    vicrit = load_crit

    serv_json({
      id:    vicrit.id,
      stars: vicrit.stars,
      input: vicrit.itext,
      btags: vicrit.btags.join(", "),
    })
  end

  def update
    vicrit = load_crit

    raise Unauthorized.new("Bạn không có quyền sửa bình luận") unless allowed?(vicrit.viuser_id)

    vicrit.changed_at = Time.utc
    vicrit.patch!(params["input"], params["stars"], params["btags"])
    serv_json(VicritView.new(vicrit, full: true))
  end

  def delete
    vicrit = load_crit

    owner_id = vicrit.viuser_id
    return halt!(403, "Bạn không có quyền xoá bình luận") unless allowed?(owner_id)

    vicrit.update!({_flag: _viuser.privi > 3 && _viuser.id != owner_id ? -3 : -2})
    serv_json({msg: "Chủ đề đã bị xoá"})
  end
end
