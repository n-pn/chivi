require "./_wn_ctrl_base"

class WN::ChapCtrl < AC::Base
  base "/_wn/chaps"

  @[AC::Route::GET("/:wn_id/:sname")]
  def index(wn_id : Int32, sname : String, pg pg_no : Int32 = 1)
    wn_seed = get_wn_seed(wn_id, sname)
    # TODO: restrict user access
    render json: wn_seed.vi_chaps.all(pg_no)
  end

  @[AC::Route::GET("/:wn_id/:sname/:ch_no/:cpart")]
  def show(wn_id : Int32, sname : String,
           ch_no : Int32, cpart : Int32,
           load_mode : Int32 = 0)
    wn_seed = get_wn_seed(wn_id, sname)
    vi_chap = get_vi_chap(wn_seed, ch_no)

    read_privi = wn_seed.read_privi
    read_privi -= 1 if ch_no <= wn_seed.gift_chaps

    zh_chap = wn_seed.zh_chap(ch_no).not_nil!
    can_read = _privi >= read_privi

    ztext = can_read ? load_ztext(wn_seed, zh_chap, cpart, load_mode) : ""

    label = "[#{cpart}/#{zh_chap.p_len}]" if zh_chap.p_len > 1
    cvmtl = ztext.empty? ? "" : load_cv_data(wn_id, ztext, label)

    vi_chap.p_len = zh_chap.p_len
    # vi_chap.c_len = zh_chap.c_len
    # vi_chap.mtime = zh_chap.mtime
    cpart = 1 if cpart < 1

    render json: {
      curr_chap: vi_chap,
      _prev_url: prev_url(wn_seed, vi_chap, cpart),
      _next_url: next_url(wn_seed, vi_chap, cpart),

      ###
      chap_data: {
        ztext: ztext,
        title: zh_chap.title,
        cvmtl: cvmtl,
        ##
        privi: read_privi,
        grant: can_read,
        cpart: cpart,
        _path: zh_chap._path,
      },
    }
  end

  HEADERS = HTTP::Headers{"Content-Type" => "text/plain"}

  private def load_cv_data(wn_id : Int32, ztext : String, label : String? = nil)
    url = "http://localhost:5010/_db/cv_chap?wn_id=#{wn_id}&cv_title=first"
    url += "&label=#{label}" if label

    HTTP::Client.post(url, headers: HEADERS, body: ztext) do |res|
      res.success? ? res.body_io.gets_to_end : ""
    end
  end

  private def load_ztext(wn_seed : WnSeed, zh_chap : WnChap, cpart : Int32, load_mode = 0)
    zh_text = zh_chap.body

    # auto reload remote texts
    if zh_text.size < 2 && should_auto_fetch?(load_mode)
      zh_text = wn_seed.fetch_text!(zh_chap, _uname, force: load_mode == 2)
    end

    # save chap text directly to `temps` folder
    unless zh_text.size < 2 || zh_chap.on_txt_dir?
      spawn zh_chap.save_body_copy!(seed: wn_seed, _flag: 2)
    end

    cpart = zh_text.size - 1 if cpart >= zh_text.size
    zh_text.size < 2 ? "" : "#{zh_text[0]}\n#{zh_text[cpart]}"
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

  private def prev_url(seed, chap : WnChap, part_no = 1)
    return chap._href(part_no - 1) if part_no > 1
    return if chap.ch_no < 2
    seed.vi_chap(chap.ch_no - 1).try(&._href(-1))
  end

  private def next_url(seed, chap : WnChap, part_no = 1)
    return chap._href(part_no + 1) if part_no < chap.p_len
    return if chap.ch_no >= seed.chap_total
    seed.vi_chap(chap.ch_no + 1).try(&._href(1))
  end
end
