require "./_wn_ctrl_base"

class WN::ChapCtrl < AC::Base
  base "/_wn/chaps"

  @[AC::Route::GET("/:wn_id/:sname")]
  def index(wn_id : Int32, sname : String, pg pg_no : Int32 = 1)
    wn_seed = get_wn_seed(wn_id, sname)
    # TODO: restrict user access
    render json: wn_seed.chaps.all(pg_no)
  end

  @[AC::Route::GET("/:wn_id/:sname/:ch_no/:cpart")]
  def show(wn_id : Int32, sname : String,
           ch_no : Int32, cpart : Int32,
           load_mode : Int32 = 0)
    wn_seed = get_wn_seed(wn_id, sname)
    wn_chap = get_wn_chap(wn_seed, ch_no)

    read_privi = wn_seed.read_privi
    read_privi -= 1 if ch_no <= wn_seed.gift_chaps

    can_read = _privi >= read_privi

    ztext = can_read ? load_ztext(wn_seed, wn_chap, cpart, load_mode) : ""

    label = "[#{cpart}/#{wn_chap.p_len}]" if wn_chap.p_len > 1
    cvmtl = ztext.empty? ? "" : load_cv_data(wn_id, ztext, label)

    cpart = 1 if cpart < 1

    render json: {
      curr_chap: wn_chap,
      _prev_url: prev_url(wn_seed, wn_chap, cpart),
      _next_url: next_url(wn_seed, wn_chap, cpart),

      ###
      chap_data: {
        title: wn_chap.title,
        ztext: ztext,
        cvmtl: cvmtl,
        ##
        privi: read_privi,
        grant: can_read,
        ##
        cpart: cpart,
        _path: wn_chap._path,
      },
    }
  end

  private def load_cv_data(wn_id : Int32, ztext : String, label : String? = nil)
    url = "#{CV_ENV.m1_host}/_m1/qtran/cv_chap?wn_id=#{wn_id}&cv_title=first"
    url += "&label=#{label}" if label

    headers = HTTP::Headers{
      "Content-Type" => "text/plain",
      "Cookie"       => context.request.headers["Cookie"],
    }

    Log.info { context.request.headers["Cookie"] }

    HTTP::Client.post(url, headers: headers, body: ztext) do |res|
      res.success? ? res.body_io.gets_to_end : ""
    end
  end

  private def load_ztext(wn_seed : WnSeed, wn_chap : WnChap, cpart : Int32, load_mode = 0)
    zh_text = wn_chap.body

    # auto reload remote texts
    if should_fetch_text?(zh_text.size < 2, load_mode)
      zh_text = wn_seed.fetch_text!(wn_chap, _uname, force: load_mode == 2)
    end

    # save chap text directly to `temps` folder
    unless zh_text.size < 2 || wn_chap.on_txt_dir?
      spawn wn_chap.save_body_copy!(seed: wn_seed, _flag: 2)
    end

    # wn_chap.p_len = zh_text.size - 1
    cpart = zh_text.size - 1 if cpart >= zh_text.size
    zh_text.size < 2 ? "" : "#{zh_text[0]}\n#{zh_text[cpart]}"
  end

  @[AlwaysInline]
  private def no_text?(body : Array(String))
    body.size < 2
  end

  @[AlwaysInline]
  private def should_fetch_text?(empty_body : Bool = false, load_mode : Int32 = 0)
    load_mode > 1 || (_privi >= 0 && empty_body)
    # _privi > 0 && (load_mode > 0 || cookies["auto_load"]?)
  end

  private def prev_url(seed, chap : WnChap, part_no = 1)
    return chap._href(part_no - 1) if part_no > 1
    return if chap.ch_no < 2

    seed.get_chap(chap.ch_no - 1).try(&._href(-1))
  end

  private def next_url(seed, chap : WnChap, part_no = 1)
    return chap._href(part_no + 1) if part_no < chap.p_len
    return if chap.ch_no >= seed.chap_total

    seed.get_chap(chap.ch_no + 1).try(&._href(1))
  end
end
