require "../../data/viuser/chtext_line_edit"

struct WN::ChtextLineForm
  include JSON::Serializable

  getter part_no : Int32
  getter line_no : Int32

  getter orig : String
  getter edit : String

  def after_initialize
    @orig = TextUtil.canon_clean(@orig)
    @edit = TextUtil.canon_clean(@edit)
  end

  def save!(seed : Wnstem, chap : Chinfo, user : String)
    repo = Chtext.new(seed, chap)

    old_ztext = repo.load_all!
    new_ztext = old_ztext.gsub(@orig, @edit)

    chap.spath = "+#{user}/#{seed.wn_id}/#{chap.ch_no}"
    repo.save_from_upload!(ztext: new_ztext, uname: user)

    spawn do
      ChtextLineEdit.new(
        wn_id: seed.wn_id, sname: seed.sname,
        ch_no: chap.ch_no, fpath: "#{chap.spath}-#{chap.cksum}",
        part_no: @part_no, line_no: @line_no,
        patch: @edit, uname: user,
      ).insert!
    rescue ex
      Log.error(exception: ex) { ex.message.colorize.red }
    end
  end
end
