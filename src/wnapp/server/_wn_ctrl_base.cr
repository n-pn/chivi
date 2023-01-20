require "../../cv_srv"
require "../data/*"

require "./views/*"
require "./forms/*"

abstract class AC::Base
  private def load_bg_seed(sname : String, s_bid : Int32)
    WN::BgSeed.get(sname, s_bid) || raise NotFound.new("Nguồn truyện không tồn tại")
  end

  private def load_fg_seed(sname : String, s_bid : Int32)
    WN::FgSeed.get(sname, s_bid) || raise NotFound.new("Nguồn truyện không tồn tại")
  end

  private def load_ch_info(seed : WN::BgSeed | WN::FgSeed, ch_no : Int32)
    seed.vi_chaps.get(ch_no).try(&.init_zh_text(seed)) || raise NotFound.new("Chương tiết không tồn tại")
  end
end
