require "json"
require "../../_util/text_util"

struct UP::UptextForm
  include JSON::Serializable

  getter ch_no : Int32
  getter title : String
  getter chdiv : String
  getter ztext : String

  def after_initialize
    raise "Nội dung quá dài!" if @ztext.size > 100_000
    raise "Vị trí chương không hợp lệ!" if @ch_no < 1

    @title = TextUtil.canon_clean(@title)
    @chdiv = TextUtil.canon_clean(@chdiv)
  end

  def save!(ustem : Upstem, uname : String = "")
    ustem.clist.save_raw_text!(@ch_no, @ztext, uname: uname)
  end
end
