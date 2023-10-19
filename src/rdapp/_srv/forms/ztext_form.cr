require "json"
require "../../../_util/text_util"
require "../../data/czdata"

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
    zdata = Czdata.new(
      ch_no: @ch_no, cbody: @ztext,
      title: @title, chdiv: @chdiv,
      uname: uname, zorig: "#{crepo.sroot}/#{@ch_no}"
    )
    crepo.save_czdata!(zdata)
  end
end
