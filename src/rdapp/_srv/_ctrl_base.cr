require "../../cv_srv"
require "../data/*"

abstract class AC::Base
  WBOOKS = {} of Int32 => RD::Wnbook
  USTEMS = {} of Int32 => RD::Upstem
  RSTEMS = {} of String => RD::Rmstem

  private def get_wbook(wn_id : Int32)
    WBOOKS[wn_id] ||= begin
      wbook = RD::Wnbook.find(wn_id) || raise "Nguồn truyện không tồn tại"
      spawn wbook.crepo.update_vinfos!
      wbook
    end
  end

  private def get_ustem(up_id : Int32, sname : String? = nil)
    USTEMS[up_id] ||= begin
      ustem = RD::Upstem.find(up_id, sname) || raise NotFound.new("Dự án không tồn tại")

      ustem.crepo.tap do |crepo|
        spawn crepo.update_vinfos!

        if crepo._flag == 0
          crepo.init_text_db!(uname: ustem.sname)
          crepo._flag = 1
          crepo.upsert!
        end
      end

      ustem
    end
  end

  private def get_rstem(sname : String, sn_id : String)
    RSTEMS["#{sname}/#{sn_id}"] ||= begin
      rstem = RD::Rmstem.find(sname, sn_id) || raise NotFound.new("Nguồn nhúng không tồn tại")

      if rstem._flag == 0
        spawn rstem.crepo.update_vinfos!
        rstem._flag == 1
      end

      rstem
    end
  end

  private def get_xstem(crepo : RD::Tsrepo)
    case crepo.stype
    when 0_i16
      get_wbook(crepo.sn_id)
    when 1_i16
      get_ustem(crepo.sn_id, crepo.sname)
    when 2_i16
      get_rstem(crepo.sname, crepo.sn_id.to_s)
    else
      raise "invalid type: #{crepo.stype}"
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
    crepo.find(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end
end
