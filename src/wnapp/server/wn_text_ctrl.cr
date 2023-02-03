require "./_wn_ctrl_base"
require "../data/viuser/ch_text_edit"
require "../data/viuser/ch_line_edit"

require "../../_util/diff_util"

class WN::TextCtrl < AC::Base
  base "/_wn/texts/:wn_id/:sname"

  @[AC::Route::GET("/:ch_no")]
  def show(wn_id : Int32, sname : String,
           ch_no : Int32)
    wn_seed = get_wn_seed(wn_id, sname)
    wn_chap = get_wn_chap(wn_seed, ch_no)

    render json: {
      ztext: wn_chap.body.join('\n'),
      title: wn_chap.title,
      chdiv: wn_chap.chdiv,
    }
  end

  def guard_sname_privi(sname : String)
    case sname
    when "_"
      guard_privi min: 1, action: "thêm chương tiết cho nguồn chính"
    when .starts_with?('@')
      guard_owner sname[1..], min: 2, action: "thêm chương tiết cho nguồn cá nhân"
    else
      guard_privi min: 3, action: "thêm chương tiết cho các nguồn phụ"
    end
  end

  @[AC::Route::POST("/")]
  def upsert_batch(wn_id : Int32, sname : String, start : Int32 = 0)
    guard_sname_privi sname: sname

    wn_seed = get_wn_seed(wn_id, sname)

    start = wn_seed.chap_total + 1 if start < 1
    ztext = request.body.not_nil!.gets_to_end

    spawn do
      save_dir = "var/texts/users/#{wn_id}-#{sname}"
      Dir.mkdir_p(save_dir)

      file_name = "#{Time.utc.to_unix // 60}-#{start}-@#{_uname}"
      file_path = "#{save_dir}/#{file_name}.txt"
      File.write(file_path, ztext)
    end

    chaps = TextSplit.split_multi(ztext)

    chaps.each_with_index(start) do |(text, chdiv), ch_no|
      wn_chap = wn_seed.get_chap(ch_no) || WnChap.new(ch_no, ch_no, "", "")
      wn_chap.chdiv = chdiv
      wn_chap.save_body!(text, seed: wn_seed, uname: _uname, _flag: 3)
    end

    wn_seed.update_stats!(start + chaps.size - 1)

    render json: {pg_no: _pgidx(start, 32)}
  end

  struct EntryForm
    include JSON::Serializable
    getter ztext : String
    getter title : String
    getter chdiv : String

    def after_initialize
      @ztext = TextUtil.clean_spaces(@ztext)
      @title = TextUtil.clean_spaces(@title)
      @chdiv = TextUtil.clean_spaces(@chdiv)
    end
  end

  @[AC::Route::PUT("/:ch_no", body: :form)]
  def upsert_entry(form : EntryForm, wn_id : Int32, sname : String, ch_no : Int32)
    guard_sname_privi sname: sname

    wn_seed = get_wn_seed(wn_id, sname)
    wn_chap = get_wn_chap(wn_seed, ch_no)

    spawn do
      ChTextEdit.new({
        sname: wn_seed.sname, s_bid: wn_seed.s_bid,
        s_cid: wn_chap.s_cid, ch_no: wn_chap.ch_no,
        patch: form.ztext, uname: _uname,
      }).save!
    rescue ex
      Log.error(exception: ex) { ex.message.colorize.red }
    end

    wn_chap.title = form.title
    wn_chap.chdiv = form.chdiv
    wn_chap._path = ""

    wn_chap.save_body!(form.ztext, seed: wn_seed, uname: _uname, _flag: 3)
    wn_seed.update_stats!(ch_no)

    render json: wn_chap
  end
end
