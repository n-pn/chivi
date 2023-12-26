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

    @title, @chdiv = ChapUtil.split_ztitle(@title, @chdiv, cleaned: false)
    @ztext = Cztext.fix_raw(@ztext)
  end

  def persist!(crepo : Tsrepo, smode = 1, uname : String = "", mtime : Int64 = 0)
    crepo.save_chap!(
      ch_no: @ch_no, title: @title,
      ztext: @ztext, chdiv: @chdiv,
      smode: smode, spath: "",
      uname: uname, mtime: mtime,
      persist: false
    )
  end
end
