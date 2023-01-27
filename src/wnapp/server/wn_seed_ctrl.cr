require "./_wn_ctrl_base"

class WN::SeedCtrl < AC::Base
  base "/_wn/seeds"

  @[AC::Route::GET("/")]
  def index(wn_id : Int32)
    seeds = WnSeed.all(wn_id)

    _main = seeds.find(&.sname.== "_") || WnSeed.new("_", wn_id, wn_id).tap(&.save!)

    render json: {
      _main: _main,
      users: seeds.select(&.sname.[0].== '@').sort_by!(&.mtime.-),
      backs: seeds.select(&.sname.[0].== '!').sort_by!(&.mtime.-),
    }
  end

  @[AC::Route::GET("/:sname/:s_bid")]
  def show(sname : String, s_bid : Int32)
    wn_seed = get_wn_seed(sname, s_bid)

    fresh = Time.utc - Time.unix(wn_seed.rtime) < 24.hours

    render json: {
      curr_seed: wn_seed,
      top_chaps: wn_seed.vi_chaps.top(4),
      seed_data: {
        stime: wn_seed.rtime,
        slink: wn_seed.slink,
        fresh: fresh,
        # extra
        min_privi: wn_seed.min_privi,
        privi_map: wn_seed.privi_map,
      },
    }
  end

  record SeedForm, sname : String, s_bid : Int32, wn_id : Int32 do
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
    raise "Không đủ quyền hạn thêm nguồn truyện" if _privi < 2

    error = form.validate!(_uname, _privi) if _privi < 3
    raise Unauthorized.new(error) if error

    WnSeed.upsert!(form.sname, form.s_bid, form.wn_id)
    render json: WnSeed.get!(form.sname, form.s_bid)
  end

  @[AC::Route::GET("/:sname/:s_bid/reload")]
  def reload(sname : String, s_bid : Int32)
    raise Unauthorized.new "Không đủ quyền hạn để cập nhật nguồn!" if _privi < 2
    wn_seed = get_wn_seed(sname, s_bid)

    if WnSeed.remote?(sname)
      wn_seed.remote_reload!
    elsif link = SeedLink.one(sname, s_bid)
      bg_seed = get_wn_seed(link.bg_sname, link.bg_s_bid)
      bg_seed.remote_reload!
    else
      raise BadRequest.new "Liên kết với nguồn ngoài để cập nhật!"
    end

    render json: wn_seed
  end
end
