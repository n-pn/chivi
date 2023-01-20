require "./_wn_ctrl_base"

class WN::TextCtrl < AC::Base
  base "/_wn"

  @[AC::Route::GET("/bgtexts/:sname/:s_bid/:ch_no")]
  def bg_text(sname : String, s_bid : Int32, ch_no : Int32, part_no : Int32? = nil)
    bg_seed = load_bg_seed(sname, s_bid)
    ch_info = load_ch_info(bg_seed, ch_no)
    render text: part_no ? ch_info.zh_text.full_text : zh_text.text_part(part_no)
  end

  @[AC::Route::GET("/fgtexts/:sname/:s_bid/:ch_no")]
  def fg_text_full(sname : String, s_bid : Int32, ch_no : Int32, part_no : Int32? = nil)
    fg_seed = load_fg_seed(sname, s_bid)
    zh_text = load_zh_text(fg_seed, ch_no)
    render text: part_no ? ch_info.zh_text.full_text : zh_text.text_part(part_no)
  end
end
