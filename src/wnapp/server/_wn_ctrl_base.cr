require "../../cv_srv"
require "../data/*"

require "./views/*"
require "./forms/*"

abstract class AC::Base
  CACHE = {} of String => WN::Wnseed

  private def get_wnseed(wn_id : Int32, sname : String)
    CACHE["#{wn_id}/#{sname}"] ||= begin
      wninfo = WN::Wnseed.load(wn_id, sname) do
        unless read_privi = WN::Wnseed.auto_create_privi(sname, _uname)
          raise NotFound.new("Nguồn truyện không tồn tại")
        end

        read_privi -= 1 if wn_id == 0

        WN::Wnseed.new(wn_id, sname, wn_id.to_s, read_privi.to_i16).upsert!
      end

      wninfo.tap(&.init!(force: false))
    end
  end

  private def get_chinfo(seed : WN::Wnseed, ch_no : Int32)
    seed.find_chap(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end
end
