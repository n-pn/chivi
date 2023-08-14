require "./_wn_ctrl_base"

class WN::SeedCtrl < AC::Base
  base "/_wn/seeds"

  @[AC::Route::GET("/")]
  def index(wn_id : Int32)
    seeds = Wnseed.all(wn_id).sort_by!(&.mtime.-)

    render json: {
      chivi: find_or_init(seeds, wn_id, "~chivi"),
      draft: find_or_init(seeds, wn_id, "~draft"),
      users: seeds.select(&.sname.[0].== '@'),
      globs: seeds.select(&.sname.[0].== '!'),
    }
  end

  private def find_or_init(seeds : Array(Wnseed), wn_id : Int32, sname : String)
    seeds.find(&.sname.== sname) || Wnseed.new(wn_id, sname).tap(&.upsert!)
  end

  @[AC::Route::GET("/:wn_id/:sname")]
  def show(wn_id : Int32, sname : String)
    wnseed = get_wnseed(wn_id, sname)

    tdiff = Time.utc - Time.unix(wnseed.rtime)
    # FIXME: change timespan according to `_flag`
    fresh = tdiff < 24.hours

    render json: {
      curr_seed: wnseed,
      top_chaps: wnseed.top_chaps(4),
      seed_data: {
        rlink: wnseed.rlink,
        rtime: wnseed.rtime,
        ##
        _flag: wnseed._flag,
        fresh: fresh,
        # extra
        read_privi: wnseed.read_privi(_uname),
        edit_privi: wnseed.edit_privi(_uname),
        gift_chaps: wnseed.lower_read_privi_count,
      },
    }
  end

  @[AC::Route::GET("/:wn_id/:sname/word_count")]
  def word_count(wn_id : Int32, sname : String, from : Int32, upto : Int32)
    wnseed = get_wnseed(wn_id, sname)
    # wnseed.reload_stats!

    render json: {
      s_bid:      wnseed.s_bid,
      chap_avail: wnseed.chap_avail,
      word_count: wnseed.word_count(from, upto),
    }
  end

  record CreateForm, wn_id : Int32, sname : String, s_bid : Int32 = -1 do
    include JSON::Serializable

    def after_initialize
      @s_bid = @wn_id if @s_bid < 0
    end

    # def validate!(uname : String, privi : Int32) : String?
    # end
  end

  @[AC::Route::PUT("/", body: :form)]
  def create(form : CreateForm)
    # user own seed list can be auto created, not needed here
    guard_privi 3, "thêm nguồn truyện"

    if form.sname[0] != '!'
      raise BadRequest.new("Tên nguồn truyện không được chấp nhận")
    end

    Wnseed.upsert!(form.wn_id, form.sname, form.s_bid)
    render json: Wnseed.get!(form.wn_id, form.sname)
  end

  @[AC::Route::GET("/:wn_id/:sname/refresh")]
  def refresh(wn_id : Int32, sname : String, mode : Int32 = 1)
    privi = SeedType.edit_privi(sname, _uname) - 1
    guard_privi privi, "cập nhật nguồn"

    wnseed = get_wnseed(wn_id, sname)
    wnseed.refresh_chlist!(mode: mode)

    render json: wnseed
  end

  # @[AC::Route::GET("/:wn_id/:sname/reconvert")]
  # def reconvert(wn_id : Int32, sname : String, min = 1, max = 99999)
  #   guard_privi 0, "dịch lại danh sách chương tiết"

  #   wnseed = get_wnseed(wn_id, sname)
  #   tdiff = Time.measure { wnseed.chaps.translate!(min, max) }
  #   render text: "#{tdiff.total_milliseconds.round}ms"
  # end

  struct UpdateForm
    include JSON::Serializable

    getter rm_link : String?
    getter cut_from : Int32?
    getter read_privi : Int32?
  end

  @[AC::Route::PATCH("/:wn_id/:sname", body: :form)]
  def update_seed(form : UpdateForm, wn_id : Int32, sname : String)
    guard_privi SeedType.edit_privi(sname, _uname), "cập nhật nguồn"
    wnseed = get_wnseed(wn_id, sname)

    if rlink = form.rm_link
      wnseed.rlink = rlink
      spawn wnseed.refresh_chlist!(mode: 1)
    end

    if cut_from = form.cut_from
      wnseed.delete_chaps!(cut_from)
    end

    if privi = form.read_privi
      wnseed.privi = privi.to_i16
    end

    wnseed.upsert!

    render json: wnseed
  end

  @[AC::Route::DELETE("/:wn_id/:sname")]
  def delete(wn_id : Int32, sname : String, mode : Int32 = 1)
    guard_privi SeedType.delete_privi(sname, _uname), "xóa danh sách chương"
    wnseed = get_wnseed(wn_id, sname)

    Wnseed.soft_delete!(wn_id, sname)
    # WnRepo.soft_delete!(wnseed.sname, wnseed.s_bid)

    render json: {message: "ok"}
  end
end
