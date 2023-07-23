require "../../cv_srv"
require "../data/*"

require "./views/*"
require "./forms/*"

abstract class AC::Base
  CACHE = {} of String => WN::WnSeed

  private def get_wn_seed(wn_id : Int32, sname : String)
    sname = "~draft" if sname[0] == '='

    CACHE["#{wn_id}/#{sname}"] ||= WN::WnSeed.get(wn_id, sname) || begin
      unless min_privi = auto_create_privi(sname)
        raise NotFound.new("Nguồn truyện không tồn tại")
      end

      min_privi -= 1 if wn_id == 0
      entry = WN::WnSeed.new(wn_id, sname, wn_id, min_privi.to_i16)

      entry.mkdirs!
      entry.upsert!

      entry
    end
  end

  private def auto_create_privi(sname : String) : Int32?
    case WN::WnSeed::Type.parse(sname)
    when .chivi? then 0
    when .draft? then 0
    when .users? then sname == "@#{_uname}" ? 2 : 5
    else              nil
    end
  end

  private def get_wn_chap(seed : WN::WnSeed, ch_no : Int32)
    seed.get_chap(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end
end
