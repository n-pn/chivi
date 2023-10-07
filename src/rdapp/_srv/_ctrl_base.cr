require "../../cv_srv"
require "../data/*"
require "./forms/*"

require "../../wnapp/data/wnstem"

abstract class AC::Base
  WNSTEMS = {} of String => WN::Wnstem
  RMSTEMS = {} of String => RD::Rmstem
  UPSTEMS = {} of Int32 => RD::Upstem

  private def get_wstem(sname : String, wn_id : Int32)
    WNSTEMS["#{wn_id}/#{sname}"] ||= begin
      wstem = WN::Wnstem.load(wn_id, sname) do
        raise NotFound.new("Nguồn truyện không tồn tại") unless sname.in?("~draft", "~avail", "~chivi")
        WN::Wnstem.new(wn_id, sname, wn_id.to_s).upsert!.tap(&.init!)
      end
    end
  end

  private def get_ustem(up_id : Int32, sname : String? = nil)
    UPSTEMS[up_id] ||= RD::Upstem.find(up_id, sname) || raise NotFound.new("Dự án không tồn tại")
  end

  private def get_rstem(sname : String, sn_id : String)
    RMSTEMS["#{sname}/#{sn_id}"] ||= RD::Rmstem.find(sname, sn_id) || raise NotFound.new("Nguồn nhúng không tồn tại")
  end

  private def get_cinfo(ustem : RD::Upstem, ch_no : Int32)
    ustem.crepo.find(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end

  private def get_cinfo(rstem : RD::Rmstem, ch_no : Int32)
    rstem.crepo.find(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end

  private def get_cinfo(wstem : WN::Wnstem, ch_no : Int32)
    wstem.find_chap(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end

  private def get_or_new_chinfo(wstem : WN::Wnstem, ch_no : Int32)
    wstem.find_chap(ch_no) || WN::Chinfo.new(ch_no)
  end
end
