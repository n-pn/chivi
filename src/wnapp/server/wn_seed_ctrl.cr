require "./_wn_ctrl_base"

class WN::SeedCtrl < AC::Base
  base "/_wn/seeds"

  @[AC::Route::GET("/")]
  def index(wn_id : Int32)
    seeds = WnSeed.all(wn_id).sort_by!(&.mtime.-)

    render json: {
      _main: find_or_init(seeds, wn_id, "_"),
      users: seeds.select(&.sname.[0].== '@'),
      backs: seeds.select(&.sname.[0].== '!'),
    }
  end

  private def find_or_init(seeds : Array(WnSeed), wn_id : Int32, sname : String)
    seeds.find(&.sname.== sname) || WnSeed.new(wn_id, sname).tap(&.save!)
  end

  @[AC::Route::GET("/:wn_id/:sname")]
  def show(wn_id : Int32, sname : String)
    wn_seed = get_wn_seed(wn_id, sname)

    tdiff = Time.utc - Time.unix(wn_seed.rm_stime)
    # FIXME: change timespan according to `_flag`
    fresh = tdiff < 24.hours

    render json: {
      curr_seed: wn_seed,
      top_chaps: wn_seed.chaps.top(4),
      seed_data: {
        links: wn_seed.remotes,
        stime: wn_seed.rm_stime,
        _flag: wn_seed._flag,
        fresh: fresh,
        # extra
        read_privi: wn_seed.read_privi,
        edit_privi: wn_seed.edit_privi,
        gift_chaps: wn_seed.gift_chaps,
      },
    }
  end

  record CreateForm, wn_id : Int32, sname : String, s_bid : Int32? do
    include JSON::Serializable

    def validate!(uname : String, privi : Int32) : String?
      case sname[0]
      when '@'
        return if sname[1..] == uname
        "Bạn chỉ được quyền thêm nguồn cho tên của mình"
      when '!'
        return if WnSeed::REMOTES.includes?(sname)
        "Tên nguồn truyện không chính xác"
      else
        "Tên nguồn truyện không được chấp nhận"
      end
    end
  end

  @[AC::Route::PUT("/", body: :form)]
  def create(form : CreateForm)
    guard_privi 2, "thêm nguồn truyện"

    error = form.validate!(_uname, _privi) if _privi < 3
    raise Unauthorized.new(error) if error

    WnSeed.upsert!(form.wn_id, form.sname, form.s_bid || form.wn_id)
    render json: WnSeed.get!(form.wn_id, form.sname)
  end

  @[AC::Route::GET("/:wn_id/:sname/refresh")]
  def refresh(wn_id : Int32, sname : String, mode : Int32 = 1)
    wn_seed = get_wn_seed(wn_id, sname)
    guard_privi wn_seed.read_privi - 1, "cập nhật nguồn"

    if slink = wn_seed.remotes.first?
      wn_seed.update_from_remote!(slink, mode: mode)
    else
      wn_seed.chaps.translate!
    end

    render json: wn_seed
  end

  struct UpdateForm
    include JSON::Serializable

    getter read_privi : Int32?
    getter rm_links : Array(String)?

    getter cut_from : Int32?
  end

  @[AC::Route::PATCH("/:wn_id/:sname", body: :form)]
  def update_seed(form : UpdateForm, wn_id : Int32, sname : String)
    wn_seed = get_wn_seed(wn_id, sname)
    guard_privi wn_seed.edit_privi("@" + _uname), "cập nhật nguồn"

    if read_privi = form.read_privi
      wn_seed.read_privi = read_privi
    end

    if rm_links = form.rm_links
      wn_seed.rm_links = rm_links
    end

    if cut_from = form.cut_from
      wn_seed.chaps.delete_chaps!(cut_from)
      wn_seed.chap_total = cut_from - 1
    end

    wn_seed.save!
    render json: wn_seed
  end

  @[AC::Route::DELETE("/:wn_id/:sname")]
  def delete(wn_id : Int32, sname : String, mode : Int32 = 1)
    guard_privi delete_privi(sname), "xóa danh sách chương"
    wn_seed = get_wn_seed(wn_id, sname)

    WnSeed.soft_delete!(wn_id, sname)
    WnRepo.soft_delete!(wn_seed.sname, wn_seed.s_bid)

    render json: {message: "ok"}
  end

  private def delete_privi(sname : String)
    case sname
    when "@#{_uname}"       then 2
    when "!chivi.app"       then 4
    when .starts_with?('!') then 3
    else                         5
    end
  end
end
