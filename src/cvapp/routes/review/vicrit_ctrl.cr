require "../_ctrl_base"

class CV::VicritCtrl < CV::BaseCtrl
  base "/_db/crits"

  @[AC::Route::GET("/")]
  def index(
    gt smin : Int32 = 0, lt smax : Int32 = 6,
    wn book : Int32? = nil, bl list : Int32? = nil,
    by user : String? = nil, lb vtag : String? = nil,
    _s sort : String = "utime", _m memo : String? = nil
  )
    pg_no, limit, offset = _paginate(min: 1, max: 24)

    crits = VicritView.fetch_all(
      self_id: _vu_id,
      order: sort, vuser: user,
      wbook: book, vlist: list,
      btags: vtag, umemo: memo,
      s_min: smin, s_max: smax,
      limit: limit, offset: offset,
    )

    total = VicritView.count_all(
      vuser: user,
      wbook: book, vlist: list,
      btags: vtag, umemo: memo,
      s_min: smin, s_max: smax,
    )

    books = Wninfo.preload(crits.map(&.wn_id))

    json = {
      crits: crits,
      books: WninfoView.as_hash(books),
      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }

    render json: json
  end

  @[AC::Route::GET("/:crit_id")]
  def show(crit_id : Int32)
    vcrit = VicritView.fetch_one(crit_id, _vu_id)
    binfo = Wninfo.find!({id: vcrit.wn_id})

    render json: {
      crit: vcrit,
      book: WninfoView.new(binfo),
    }
  end

  private def load_crit(id : Int64)
    Vicrit.find({id: id}) || raise NotFound.new("Bình luận không tồn tại!")
  end

  @[AC::Route::GET("/form")]
  def upsert_form(wn wn_id : Int32 = 0, id vc_id : Int32 = 0)
    guard_privi 0, "thêm/sửa đánh giá"

    Vilist.load!(-_vu_id) # make sure that user default booklist exists
    lists = VilistCard.all_by_user(_vu_id, _vu_id)

    crits = VicritView.fetch_all(self_id: _vu_id, vuser: _uname, wbook: wn_id)

    vcrit = crits.find(&.vc_id.== vc_id)
    wn_id = vcrit.wn_id if vcrit && wn_id == 0

    crits.reject!(&.vc_id.== vc_id) if vcrit

    fdata = {
      cform: init_form(vcrit, wn_id),
      ctime: vcrit.try(&.ctime) || 0,
      bname: Wninfo.get_btitle_vi(wn_id),
      lists: lists,
      crits: crits,
    }

    render json: fdata
  end

  private def init_form(crit : Nil, wn_id : Int32)
    {id: 0, wn_id: wn_id, vl_id: -_vu_id, stars: 3, input: "", btags: ""}
  end

  private def init_form(crit : VicritView, wn_id : Int32)
    vl_id, itext = Vicrit.get_form_data(crit.vc_id)

    {
      id: crit.vc_id, wn_id: wn_id, vl_id: vl_id,
      stars: crit.stars, input: itext, btags: crit.btags.join(", "),
    }
  end

  struct CritForm
    include JSON::Serializable

    getter wn_id : Int32
    getter vl_id : Int32?

    getter input : String
    getter stars : Int32 = 3
    getter btags : String

    def after_initialize
      @input = @input.strip
      @stars = 3 unless @stars.in?(1..5)
      @vl_id = nil if @vl_id == 0
    end

    def tag_list
      @btags.split(',').map!(&.strip).reject!(&.empty?).uniq!(&.downcase)
    end
  end

  @[AC::Route::POST("/", body: form)]
  def create(form : CritForm)
    guard_privi 0, "tạo đánh giá"

    vcrit = Vicrit.new({
      viuser_id: self._vu_id,
      nvinfo_id: form.wn_id,
      vilist_id: form.vl_id || -_vu_id,
    })

    vcrit.patch!(form.input, form.stars, form.tag_list)
    spawn Vilist.inc_counter(vcrit.vilist_id, "book_count")
    render json: {uname: self._uname, vc_id: vcrit.id}
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
    vcrit = load_crit(crit_id)

    owner_id = vcrit.viuser_id
    guard_owner owner_id, 0, "sửa đánh giá"

    old_list_id = vcrit.vilist_id
    new_list_id = form.vl_id || old_list_id

    if old_list_id != new_list_id
      spawn do
        Vilist.dec_counter(old_list_id, "book_count")
        Vilist.inc_counter(new_list_id, "book_count")
      end
    end

    vcrit.vilist_id = new_list_id
    vcrit.changed_at = Time.utc
    vcrit.patch!(form.input, form.stars, form.tag_list)

    render json: {uname: self._uname, vc_id: vcrit.id}
  end

  @[AC::Route::DELETE("/:crit_id")]
  def delete(crit_id : Int32)
    vcrit = load_crit(crit_id)

    spawn Vilist.dec_counter(vcrit.vilist_id, "book_count")

    owner_id = vcrit.viuser_id
    guard_owner owner_id, 0, "xoá đánh giá"

    is_admin = _privi > 3 && _vu_id != owner_id
    vcrit.update!({_flag: is_admin ? -3 : -2})

    render json: {msg: "đánh giá đã bị xoá"}
  end
end
