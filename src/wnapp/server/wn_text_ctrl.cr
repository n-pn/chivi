require "./_wn_ctrl_base"

class WN::TextCtrl < AC::Base
  base "/_wn"

  @[AC::Route::GET("/texts/:sname/:s_bid/:ch_no")]
  def show(sname : String, s_bid : Int32,
           ch_no : Int32, part_no : Int32? = nil,
           load_mode : Int32 = 0)
    wn_seed = get_wn_seed(sname, s_bid)
    zh_chap = get_zh_chap(wn_seed, ch_no)

    ch_body = zh_chap.body

    # auto reload remote texts
    if !no_text?(ch_body) && should_auto_fetch?(load_mode)
      wn_seed.fetch_text!(zh_chap, _uname, force: load_mode == 2)
    end

    # save chap text directly to `temps` folder
    unless no_text?(ch_body) || zh_chap.on_temp_dir?
      spawn zh_chap.save_body_copy!(seed: wn_seed)
    end

    # put extra metadata
    response.headers["X-TITLE"] = zh_chap.title
    response.headers["X-CHDIV"] = zh_chap.chdiv

    if part_no && (text_part = ch_body[part_no]?)
      render text: "#{ch_body[0]}\n#{text_part}"
    else
      render text: ch_body.join('\n')
    end
  end

  @[AlwaysInline]
  private def no_text?(body : Array(String))
    body.size < 2
  end

  @[AlwaysInline]
  private def should_auto_fetch?(load_mode : Int32)
    _privi > 0 && (load_mode > 0 || cookies["auto_fetch"])
  end
end
