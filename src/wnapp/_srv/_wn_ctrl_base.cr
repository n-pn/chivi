require "../../cv_srv"
require "../data/*"

require "./views/*"
require "./forms/*"

abstract class AC::Base
  CACHE = {} of String => WN::Wnstem

  private def get_wnseed(wn_id : Int32, sname : String)
    CACHE["#{wn_id}/#{sname}"] ||= begin
      wninfo = WN::Wnstem.load(wn_id, sname) do
        raise "invalid" unless read_privi = map_read_privi(sname)
        WN::Wnstem.new(wn_id, sname, wn_id.to_s, read_privi.to_i16).upsert!
      end

      wninfo.tap(&.init!(force: false))
    end
  end

  private def map_read_privi(sname : String)
    case sname
    when "~draft" then 1
    when "~avail" then 2
    when "~chivi" then 3
    end
  end

  private def get_chinfo(seed : WN::Wnstem, ch_no : Int32)
    seed.find_chap(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end

  private def get_or_new_chinfo(seed : WN::Wnstem, ch_no : Int32)
    seed.find_chap(ch_no) || WN::Chinfo.new(ch_no)
  end
end
