require "../../cv_srv"
require "../data/*"

require "./views/*"
require "./forms/*"

abstract class AC::Base
  private def get_wn_seed(wn_id : Int32, sname : String)
    WN::WnSeed.get(wn_id, sname) || begin
      raise NotFound.new("Nguồn truyện không tồn tại") unless auto_seed?(sname)
      entry = WN::WnSeed.new(wn_id, sname, wn_id).tap(&.mkdirs!)
      entry.tap(&.save!)
    end
  end

  private def auto_seed?(sname : String)
    case sname
    when "-"          then true
    when "@#{_uname}" then _privi > 1
    else                   false
    end
  end

  private def get_vi_chap(seed : WN::WnSeed, ch_no : Int32)
    seed.vi_chap(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end

  private def get_zh_chap(seed : WN::WnSeed, ch_no : Int32)
    seed.zh_chap(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end
end
