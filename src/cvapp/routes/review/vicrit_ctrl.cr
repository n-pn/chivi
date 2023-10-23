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

    crits = VicritView.fetch_all(
      self_id: _vu_id, order: sort,
      vuser: from == "me" ? _uname : user,
      wbook: book, vlist: list, btags: vtag,
      s_min: smin, s_max: smax,
      limit: limit, offset: offset,
    )

    total = VicritView.count_all(
      vuser: from == "me" ? _uname : user,
      wbook: book, vlist: list, btags: vtag,
      s_min: smin, s_max: smax,
    )

    books = Wninfo.preload(crits.map(&.wn_id))

    render json: {
      crits: crits,
      books: WninfoView.as_hash(books),
      total: total,
      pgidx: pg_no,
      pgmax: _pgidx(total, limit),
    }
  end

  @[AC::Route::GET("/:crit_id")]
  def show(crit_id : Int32)
    render json: VicritView.fetch_one(crit_id, _vu_id)
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
    crits.reject!(&.vc_id.== vc_id) if vcrit

    render json: {
      ctime: vcrit.try(&.ctime) || 0,
      cform: init_form(vcrit, wn_id),

      lists: lists,
      crits: crits,
    }
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

    vicrit = Vicrit.new({
      viuser_id: _viuser.id,
      nvinfo_id: form.wn_id,
      vilist_id: form.vl_id || -_vu_id,
    })

    vicrit.patch!(form.input, form.stars, form.tag_list)
    spawn Vilist.inc_counter(vicrit.vilist_id, "book_count")

    render text: vicrit.id
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
    new_list_id = form.vl_id || old_list_id

    if old_list_id != new_list_id
      spawn do
        Vilist.dec_counter(old_list_id, "book_count")
        Vilist.inc_counter(new_list_id, "book_count")
      end
    end

    vicrit.vilist_id = new_list_id
    vicrit.changed_at = Time.utc
    vicrit.patch!(form.input, form.stars, form.tag_list)

    render text: vicrit.id
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
