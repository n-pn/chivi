require "json"
require "../../_util/text_util"
require "../data/czdata"

struct RD::ZcdataForm
  include JSON::Serializable

  getter ch_no : Int32
  getter ztext : String
  getter title : String = ""
  getter chdiv : String = ""

  def after_initialize
    raise "Vị trí chương không hợp lệ!" if @ch_no < 1
    raise "Nội dung quá dài!" if @ztext.size > 100_000

    @title = TextUtil.canon_clean(@title)
    @chdiv = TextUtil.canon_clean(@chdiv)
  end

  def save!(crepo : Tsrepo, tmdir : String, uname : String = "", edit_mode : Bool = false)
    zdata = Czdata.new(
      ch_no: @ch_no, cbody: @ztext,
      title: @title, chdiv: @chdiv,
      uname: uname, zorig: "#{crepo.sroot}/#{@ch_no}"
    )

    suffix = edit_mode ? '1' : '0'
    txt_file = "#{tmdir}/#{ch_no}#{suffix}.zh"
    File.write(txt_file, "///#{chdiv}\n#{zdata.parts}")

    crepo.save_czdata!(zdata)
  end
end
