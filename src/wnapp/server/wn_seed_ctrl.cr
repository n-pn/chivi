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
      top_chaps: wn_seed.vi_chaps.top(4),
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

  record SeedForm, wn_id : Int32, sname : String, s_bid : Int32? do
    include JSON::Serializable

    def validate!(uname : String, privi : Int32) : String?
      case sname[0]
      when '@'
        return if sname[1..] == uname
        "Bạn chỉ được quyền thêm nguồn cho tên của mình"
      when '!'
        "Tên nguồn truyện không chính xác" unless WnSeed.remote?(sname)
      else
        "Tên nguồn truyện không được chấp nhận"
      end
    end
  end

  @[AC::Route::POST("/", body: :form)]
  def upsert(form : SeedForm)
    guard_privi 2, "thêm nguồn truyện"

    error = form.validate!(_uname, _privi) if _privi < 3
    raise Unauthorized.new(error) if error

    WnSeed.upsert!(form.wn_id, form.sname, form.s_bid || form.wn_id)
    render json: WnSeed.get!(form.wn_id, form.sname)
  end

  @[AC::Route::GET("/:wn_id/:sname/refresh")]
  def refresh(wn_id : Int32, sname : String, mode : Int32 = 1)
    wn_seed = get_wn_seed(wn_id, sname)
    guard_privi wn_seed.min_privi - 1, "cập nhật nguồn"

    if slink = wn_seed.remotes.first?
      wn_seed.update_from_remote!(slink, mode: mode)
    else
      wn_seed.reload_content!
    end

    render json: wn_seed
  end
end
