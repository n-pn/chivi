require "../../cv_srv"
require "../data/*"

abstract class AC::Base
  STEMS = {} of Int32 => UP::Upstem

  private def get_ustem(up_id : Int32)
    STEMS[up_id] ||= UP::Upstem.find(up_id) || raise NotFound.new("Dự án không tồn tại")
  end

  private def get_cinfo(ustem : UP::Upstem, ch_no : Int32)
    ustem.clist.find(ch_no) || raise NotFound.new("Chương tiết không tồn tại")
  end
end
