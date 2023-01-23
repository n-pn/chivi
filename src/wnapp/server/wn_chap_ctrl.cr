require "./_wn_ctrl_base"

class WN::ChapCtrl < AC::Base
  base "/_wn/chaps"

  @[AC::Route::GET("/:sname/:s_bid")]
  def index(sname : String, s_bid : Int32, pg pg_no : Int32 = 1)
    wn_seed = get_wn_seed(sname, s_bid)
    # TODO: restrict user access
    render json: wn_seed.vi_chaps.all(pg_no)
  end

  @[AC::Route::GET("/:sname/:s_bid/:ch_no/:part_no")]
  def show(sname : String, s_bid : Int32,
           ch_no : Int32, part_no : Int32,
           load_mode : Int32 = 0)
    wn_seed = get_wn_seed(sname, s_bid)
    vi_chap = get_vi_chap(wn_seed, ch_no)

    zh_chap = get_zh_chap(wn_seed, ch_no)
    zh_text = zh_chap.body

    # auto reload remote texts
    if !no_text?(zh_text) && should_auto_fetch?(load_mode)
      wn_seed.fetch_text!(zh_chap, _uname, force: load_mode == 2)
    end

    # save chap text directly to `temps` folder
    # unless no_text?(zh_text) || zh_chap.on_temp_dir?
    #   spawn zh_chap.save_body_copy!(seed: wn_seed)
    # end

    ztext = String.build do |io|
      io << zh_text[0]
      zh_text[part_no + 1]?.try { |x| io << '\n' << x }
    end

    render json: {
      ztext: ztext,
      _chap: vi_chap,
      _prev: prev_url(wn_seed, vi_chap, part_no),
      _next: next_url(wn_seed, vi_chap, part_no),
    }
  end

  @[AlwaysInline]
  private def no_text?(body : Array(String))
    body.size < 2
  end

  @[AlwaysInline]
  private def should_auto_fetch?(load_mode : Int32)
    _privi > 0 && (load_mode > 0 || cookies["auto_load"]?)
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
