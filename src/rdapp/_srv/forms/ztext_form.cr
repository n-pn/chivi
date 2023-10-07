require "json"
require "../../../_util/text_util"

struct RD::ZtextForm
  include JSON::Serializable

  getter ch_no : Int32
  getter ztext : String
  getter title : String = ""
  getter chdiv : String = ""

  def after_initialize
    raise "Nội dung quá dài!" if @ztext.size > 100_000
    raise "Vị trí chương không hợp lệ!" if @ch_no < 1

    @title = TextUtil.canon_clean(@title)
    @chdiv = TextUtil.canon_clean(@chdiv)
  end

  def save!(crepo : Chrepo, uname : String = "")
    crepo.save_raw!(@ch_no, @ztext, uname: uname, title: title, chdiv: chdiv)
  end
end
