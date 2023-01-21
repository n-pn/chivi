require "../../cv_srv"
require "../data/*"

require "./views/*"
require "./forms/*"

abstract class AC::Base
  private def get_wn_seed(sname : String, s_bid : Int32)
    WN::WnSeed.get(sname, s_bid) || raise NotFound.new("Nguồn truyện không tồn tại")
  end

  private def get_zh_chap(seed : WN::WnSeed, ch_no : Int32)
    seed.zh_chap(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end
end
