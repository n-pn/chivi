require "../../data/viuser/chtext_full_edit"

struct WN::ChtextFullForm
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

  def save!(seed : Wnsterm,
            chap : Chinfo = seed.load_chap(@ch_no),
            user : String = "") : Chinfo
    repo = Chtext.new(seed, chap)

    chap.ztitle = @title
    chap.zchdiv = @chdiv
    chap.spath = "+#{user}/#{seed.wn_id}/#{chap.ch_no}"

    repo.save_from_upload!(ztext: @ztext, uname: user)
    spawn log_action!(seed, chap, user)

    chap
  end

  private def log_action!(seed, chap, user)
    ChtextFullEdit.new(
      wn_id: seed.wn_id, sname: seed.sname,
      ch_no: chap.ch_no, fpath: "#{chap.spath}-#{chap.cksum}",
      uname: user,
    ).insert!
  rescue ex
    Log.error(exception: ex) { ex.message.colorize.red }
  end
end
