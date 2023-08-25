require "../../cv_srv"
require "../data/*"

require "./views/*"
require "./forms/*"

abstract class AC::Base
  CACHE = {} of String => WN::Wnsterm

  private def get_wnseed(wn_id : Int32, sname : String)
    CACHE["#{wn_id}/#{sname}"] ||= begin
      wninfo = WN::Wnsterm.load(wn_id, sname) do
        unless read_privi = WN::Wnsterm.auto_create_privi(sname, _uname)
          raise NotFound.new("Nguồn truyện không tồn tại")
        end

        read_privi -= 1 if wn_id == 0

        WN::Wnsterm.new(wn_id, sname, wn_id.to_s, read_privi.to_i16).upsert!
      end

      wninfo.tap(&.init!(force: false))
    end
  end

  private def get_chinfo(seed : WN::Wnsterm, ch_no : Int32)
    seed.find_chap(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end

  private def get_or_new_chinfo(seed : WN::Wnsterm, ch_no : Int32)
    seed.find_chap(ch_no) || WN::Chinfo.new(ch_no)
  end
end
