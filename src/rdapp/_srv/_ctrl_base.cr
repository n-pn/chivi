require "../../cv_srv"
require "../data/*"

abstract class AC::Base
  WBOOKS = {} of Int32 => RD::Wnbook
  USTEMS = {} of Int32 => RD::Upstem
  RSTEMS = {} of String => RD::Rmstem

  private def get_wbook(wn_id : Int32)
    WBOOKS[wn_id] ||= begin
      RD::Wnbook.find(wn_id) || raise "Nguồn truyện không tồn tại"
    end
  end

  private def get_ustem(up_id : Int32, sname : String? = nil)
    USTEMS[up_id] ||= begin
      RD::Upstem.find(up_id, sname) || raise NotFound.new("Dự án không tồn tại")
    end
  end

  private def get_rstem(sname : String, sn_id : Int32)
    RSTEMS["#{sname}/#{sn_id}"] ||= begin
      RD::Rmstem.find(sname, sn_id) || raise NotFound.new("Nguồn nhúng không tồn tại")
    end
  end

  private def get_xstem(crepo : RD::Tsrepo)
    case crepo.stype
    when 0_i16
      get_wbook(crepo.sn_id)
    when 1_i16
      get_ustem(crepo.sn_id, crepo.sname)
    when 2_i16
      get_rstem(crepo.sname, crepo.sn_id)
    else
      raise "invalid type: #{crepo.stype}"
    end
  end

  private def get_xstem(sname : String, sn_id : Int32)
    case sname
    when .starts_with?("wn")
      get_wbook(sn_id)
    when .starts_with?("up")
      get_ustem(sn_id)
    when .starts_with?("rm")
      get_rstem(sname[2..], sn_id)
    else
      raise "invalid type: #{sname}"
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
  private def get_cinfo(crepo : RD::Tsrepo, ch_no : Int32)
    crepo.get_cinfo(ch_no) { raise NotFound.new("Chương tiết không tồn tại") }
  end
end
