require "json"
require "../../_util/text_util"
require "../data/czdata"

struct RD::CzdataForm
  include JSON::Serializable

  getter ch_no : Int32
  getter ztext : String
  getter title : String = ""
  getter chdiv : String = ""

  def after_initialize
    raise "Vị trí chương không hợp lệ!" if @ch_no < 1
    raise "Nội dung quá dài!" if @ztext.size > 100_000

    @title, @chdiv = ChapUtil.split_ztitle(@title, @chdiv, cleaned: false)
  end

  def to_czdata(db, _user : String, mtime : Int64 = Time.utc.to_unix) : Czdata
    zdata = Czdata.load(db, @ch_no)
    # TODO: skip if immutable

    zdata.title = @title
    zdata.chdiv = @chdiv
    zdata.mtime = mtime
    zdata._user = _user
    zdata.init_by_hand(input: @ztext)

    zdata
  end
end
