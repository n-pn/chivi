require "./_wn_ctrl_base"

class WN::ChapCtrl < AC::Base
  base "/_wn/chaps"

  @[AC::Route::GET("/:wn_id/:sname")]
  def index(wn_id : Int32, sname : String, pg pg_no : Int32 = 1)
    wn_seed = get_wn_seed(wn_id, sname)
    # TODO: restrict user access
    render json: wn_seed.vi_chaps.all(pg_no)
  end

  @[AC::Route::GET("/:wn_id/:sname/:ch_no/:part_no")]
  def show(wn_id : Int32, sname : String,
           ch_no : Int32, part_no : Int32,
           load_mode : Int32 = 0)
    wn_seed = get_wn_seed(wn_id, sname)
    vi_chap = get_vi_chap(wn_seed, ch_no)

    min_privi = wn_seed.min_privi("+#{_uname}")
    min_privi -= 1 if ch_no <= wn_seed.chap_total // 3

    zh_chap = wn_seed.zh_chap(ch_no).not_nil!
    can_read = _privi >= min_privi

    ztext = can_read ? load_ztext(wn_seed, zh_chap, part_no, load_mode) : ""
    cvmtl = ztext.empty? ? "" : load_cv_data(wn_id, ztext)

    render json: {
      curr_chap: vi_chap,
      _prev_url: prev_url(wn_seed, vi_chap, part_no),
      _next_url: next_url(wn_seed, vi_chap, part_no),
      ###
      chap_data: {
        ztext: ztext,
        title: zh_chap.title,
        cvmtl: cvmtl,
        ##
        privi: min_privi,
        grant: can_read,
      },
    }
  end

  HEADERS = HTTP::Headers{"Content-Type" => "text/plain"}

  private def load_cv_data(wn_id : Int32, ztext : String)
    url = "http://localhost:5010/_db/cv_chap?wn_id=#{wn_id}&cv_title=first"

    HTTP::Client.post(url, headers: HEADERS, body: ztext) do |res|
      res.success? ? res.body_io.gets_to_end : ""
    end
  end

  private def load_ztext(wn_seed : WnSeed, zh_chap : WnChap, part_no : Int32, load_mode = 0)
    zh_text = zh_chap.body

    # auto reload remote texts
    if no_text?(zh_text) && should_auto_fetch?(load_mode)
      zh_text = wn_seed.fetch_text!(zh_chap, _uname, force: load_mode == 2)
    end

    # save chap text directly to `temps` folder
    unless no_text?(zh_text) || zh_chap.on_txt_dir?
      spawn zh_chap.save_body_copy!(seed: wn_seed)
    end

    no_text?(zh_text) ? "" : "#{zh_text[0]}\n#{zh_text[part_no &+ 1]}"
  end

  @[AlwaysInline]
  private def no_text?(body : Array(String))
    body.size < 2
  end

  @[AlwaysInline]
  private def should_auto_fetch?(load_mode : Int32)
    _privi > 0
    # _privi > 0 && (load_mode > 0 || cookies["auto_load"]?)
  end

  private def prev_url(seed, chap : WnChap, part_no = 0)
    return chap._href(part_no - 1) if part_no > 0
    return if chap.ch_no < 2
    seed.vi_chap(chap.ch_no - 1).try(&._href(-1))
  end

  private def next_url(seed, chap : WnChap, part_no = 0)
    return chap._href(part_no + 1) if part_no + 1 < chap.p_len
    return if chap.ch_no >= seed.chap_total
    seed.vi_chap(chap.ch_no + 1).try(&._href(0))
  end
end
