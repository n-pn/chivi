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
  rescue ex : NotFound
    render 404, text: ex.message
  end

  def guard_edit_privi(wn_id : Int32, sname : String)
    type = WnSeed::Type.parse(sname)

    edit_privi = type.edit_privi(sname == "@#{_uname}")
    edit_privi -= 1 if wn_id == 0

    guard_privi edit_privi, action: "thêm chương tiết cho nguồn #{type.type_name}"
  end

  @[AC::Route::POST("/")]
  def bulk_upsert(wn_id : Int32, sname : String, start : Int32 = 0)
    guard_edit_privi wn_id: wn_id, sname: sname

    wn_seed = get_wn_seed(wn_id, sname)
    wn_seed.mkdirs!

    start = wn_seed.chap_total + 1 if start < 1
    ztext = request.body.try(&.gets_to_end) || ""

    spawn do
      save_dir = "var/texts/users/#{wn_id}-#{sname}"
      Dir.mkdir_p(save_dir)

      file_name = "#{Time.utc.to_unix // 60}-#{start}-[#{_uname}]"
      file_path = "#{save_dir}/#{file_name}.txt"
      File.write(file_path, ztext)
    end

    chaps = TextSplit.split_multi(ztext, cleaned: false)

    chaps.each_with_index(start) do |entry, ch_no|
      raise BadRequest.new "Invalid input" if entry.lines.empty?

      wn_chap = wn_seed.get_chap(ch_no) || WnChap.new(ch_no, ch_no, "", "")

      wn_chap.chdiv = entry.chdiv
      wn_chap.title = entry.lines.first

      wn_chap.save_body!(entry.lines, seed: wn_seed, uname: _uname, _flag: 3)
    end

    chmax = start + chaps.size - 1
    wn_seed.update_stats!(chmax)
    wn_seed.chaps.translate!(start, chmax)

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
  def upsert_chap(form : EntryForm, wn_id : Int32, sname : String, ch_no : Int32)
    guard_edit_privi wn_id: wn_id, sname: sname

    wn_seed = get_wn_seed(wn_id, sname)
    wn_chap = get_wn_chap(wn_seed, ch_no)
    wn_seed.mkdirs!

    spawn do
      ChTextEdit.new(
        sname: wn_seed.sname, s_bid: wn_seed.s_bid,
        s_cid: wn_chap.s_cid, ch_no: wn_chap.ch_no,
        patch: form.ztext, uname: _uname,
      ).create!
    rescue ex
      Log.error(exception: ex) { ex.message.colorize.red }
    end

    wn_chap.title = form.title
    wn_chap.chdiv = form.chdiv
    wn_chap._path = ""

    wn_chap.save_body!(form.ztext, seed: wn_seed, uname: _uname, _flag: 3)

    wn_seed.update_stats!(ch_no)
    wn_seed.chaps.translate!(ch_no, ch_no)

    render json: wn_chap
  end

  struct PatchForm
    include JSON::Serializable
    getter part_no : Int32
    getter line_no : Int32

    getter orig : String
    getter edit : String

    def after_initialize
      @orig = TextUtil.clean_spaces(@orig)
      @edit = TextUtil.clean_spaces(@edit)
    end
  end

  @[AC::Route::PATCH("/:ch_no", body: :form)]
  def update_line(form : PatchForm, wn_id : Int32, sname : String, ch_no : Int32)
    guard_edit_privi wn_id: wn_id, sname: sname

    wn_seed = get_wn_seed(wn_id, sname)
    wn_chap = get_wn_chap(wn_seed, ch_no)

    spawn do
      ChLineEdit.new(
        sname: wn_seed.sname, s_bid: wn_seed.s_bid,
        s_cid: wn_chap.s_cid, ch_no: wn_chap.ch_no,
        part_no: form.part_no, line_no: form.line_no,
        patch: form.edit, uname: _uname,
      ).create!
    rescue ex
      Log.error(exception: ex) { ex.message.colorize.red }
    end

    wn_chap.c_len += form.edit.size - form.orig.size

    if form.line_no == 0
      raise "input mismatch" if form.orig != wn_chap.body[0]

      wn_chap.body[0] = form.edit
    else
      ch_part = wn_chap.body[form.part_no].lines
      line_no = form.line_no - 1
      raise "input mismatch" if form.orig != ch_part[line_no]

      ch_part[line_no] = form.edit
      wn_chap.body[form.part_no] = ch_part.join('\n')
    end

    ztext = wn_chap.body.join('\n')

    wn_chap.save_body!(ztext, seed: wn_seed, uname: _uname, _flag: 3)
    wn_seed.update_stats!(ch_no)

    render json: wn_chap
  end
end
