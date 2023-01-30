require "../../cv_srv"
require "../data/*"

require "./views/*"
require "./forms/*"

abstract class AC::Base
  CACHE = {} of String => WN::WnSeed

  private def get_wn_seed(wn_id : Int32, sname : String)
    CACHE["#{wn_id}/#{sname}"] ||= WN::WnSeed.get(wn_id, sname) || begin
      unless min_privi = auto_min_privi(sname)
        raise NotFound.new("Nguồn truyện không tồn tại")
      end

      min_privi -= 1 if wn_id == 0
      entry = WN::WnSeed.new(wn_id, sname, wn_id, min_privi)

      entry.mkdirs!
      entry.save!

      entry
    end
  end

  private def auto_min_privi(sname : String) : Int32?
    return 1 if sname == "_"
    return if sname != "@#{_uname}"
    return 2 if _privi > 1
  end

  private def get_vi_chap(seed : WN::WnSeed, ch_no : Int32)
    seed.vi_chap(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end

  private def get_zh_chap(seed : WN::WnSeed, ch_no : Int32)
    seed.zh_chap(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end
end
