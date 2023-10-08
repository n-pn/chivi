require "../../cv_srv"
require "../data/*"
require "../view/*"
require "./forms/*"

abstract class AC::Base
  WNSTEMS = {} of String => RD::Wnstem
  RMSTEMS = {} of String => RD::Rmstem
  UPSTEMS = {} of Int32 => RD::Upstem

  private def get_wstem(sname : String, wn_id : Int32)
    WNSTEMS["#{wn_id}/#{sname}"] ||= begin
      RD::Wnstem.load(wn_id, sname) do
        raise NotFound.new("Nguồn truyện không tồn tại") unless sname.in?("~draft", "~avail", "~chivi")
        Dir.mkdir_p("var/texts/wn#{sname}/#{wn_id}")
        RD::Wnstem.new(wn_id, sname, wn_id.to_s).upsert!
      end
    end
  end

  @[AlwaysInline]
  private def get_ustem(up_id : Int32, sname : String? = nil)
    UPSTEMS[up_id] ||= RD::Upstem.find(up_id, sname) || raise NotFound.new("Dự án không tồn tại")
  end

  @[AlwaysInline]
  private def get_rstem(sname : String, sn_id : String)
    RMSTEMS["#{sname}/#{sn_id}"] ||= begin
      rstem = RD::Rmstem.find(sname, sn_id)
      raise NotFound.new("Nguồn nhúng không tồn tại") unless rstem

      if rstem._flag == 0 && rstem.chap_count > 0
        rstem.crepo.update_vinfos!
        rstem.update_flag!(1_i16)
      end

      rstem
    end
  end

  @[AlwaysInline]
  private def get_cinfo(ustem : RD::Upstem, ch_no : Int32)
    get_cinfo(ustem.crepo, ch_no)
  end

  @[AlwaysInline]
  private def get_cinfo(rstem : RD::Rmstem, ch_no : Int32)
    get_cinfo(rstem.crepo, ch_no)
  end

  @[AlwaysInline]
  private def get_cinfo(wstem : RD::Wnstem, ch_no : Int32)
    get_cinfo(wstem.crepo, ch_no)
  end

  @[AlwaysInline]
  private def get_cinfo(crepo : RD::Chrepo, ch_no : Int32)
    crepo.find(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end
end
