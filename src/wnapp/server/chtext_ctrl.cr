require "./_wn_ctrl_base"
require "../data/viuser/ch_text_edit"
require "../data/viuser/ch_line_edit"

require "../../_util/diff_util"

class WN::ChtextCtrl < AC::Base
  base "/_wn/texts/:wn_id/:sname"

  @[AC::Route::GET("/:ch_no")]
  def show(wn_id : Int32, sname : String, ch_no : Int32)
    wnseed = get_wnseed(wn_id, sname)
    chinfo = get_chinfo(wnseed, ch_no)

    zctext = Zctext.new(wnseed, chinfo)

    render json: {
      ztext: zctext.load_all!,
      title: chinfo.ztitle,
      chdiv: chinfo.zchdiv,
    }
  rescue ex : NotFound
    render 404, text: ex.message
  end

  def guard_edit_privi(wn_id : Int32, sname : String)
    type = SeedType.parse(sname)

    edit_privi = type.edit_privi(sname == "@#{_uname}")
    edit_privi -= 1 if wn_id == 0

    guard_privi edit_privi, action: "thêm chương tiết cho nguồn #{type.type_name}"
  end

  # @[AC::Route::POST("/")]
  # def bulk_upsert(wn_id : Int32, sname : String, start : Int32 = 0)
  #   guard_edit_privi wn_id: wn_id, sname: sname

  #   wnseed = get_wnseed(wn_id, sname)
  #   wnseed.mkdirs!

  #   start = wnseed.chap_total + 1 if start < 1
  #   ztext = request.body.try(&.gets_to_end) || ""

  #   spawn do
  #     save_dir = "var/texts/users/#{wn_id}-#{sname}"
  #     Dir.mkdir_p(save_dir)

  #     file_name = "#{Time.utc.to_unix // 60}-#{start}-[#{_uname}]"
  #     file_path = "#{save_dir}/#{file_name}.txt"
  #     File.write(file_path, ztext)
  #   end

  #   chaps = TextSplit.split_multi(ztext, cleaned: false)

  #   chaps.each_with_index(start) do |entry, ch_no|
  #     raise BadRequest.new "Invalid input" if entry.lines.empty?

  #     chinfo = wnseed.find_chap(ch_no) || Chinfo.new(ch_no, ch_no, "", "")

  #     chinfo.chdiv = entry.chdiv
  #     chinfo.title = entry.lines.first

  #     chinfo.save_body!(entry.lines, seed: wnseed, uname: _uname, _flag: 3)
  #   end

  #   chmax = start + chaps.size - 1
  #   wnseed.update_stats!(chmax)
  #   wnseed.chaps.translate!(start, chmax)

  #   render json: {pg_no: _pgidx(start, 32)}
  # end

  # struct EntryForm
  #   include JSON::Serializable
  #   getter ztext : String
  #   getter title : String
  #   getter chdiv : String

  #   def after_initialize
  #     @ztext = TextUtil.clean_spaces(@ztext)
  #     @title = TextUtil.clean_spaces(@title)
  #     @chdiv = TextUtil.clean_spaces(@chdiv)
  #   end
  # end

  # @[AC::Route::PUT("/:ch_no", body: :form)]
  # def upsert_chap(form : EntryForm, wn_id : Int32, sname : String, ch_no : Int32)
  #   guard_edit_privi wn_id: wn_id, sname: sname

  #   wnseed = get_wnseed(wn_id, sname)
  #   chinfo = get_chinfo(wnseed, ch_no)
  #   wnseed.mkdirs!

  #   spawn do
  #     ChTextEdit.new(
  #       sname: wnseed.sname, s_bid: wnseed.s_bid,
  #       s_cid: chinfo.s_cid, ch_no: chinfo.ch_no,
  #       patch: form.ztext, uname: _uname,
  #     ).insert!
  #   rescue ex
  #     Log.error(exception: ex) { ex.message.colorize.red }
  #   end

  #   chinfo.title = form.title
  #   chinfo.chdiv = form.chdiv
  #   chinfo._path = ""

  #   chinfo.save_body!(form.ztext, seed: wnseed, uname: _uname, _flag: 3)

  #   wnseed.update_stats!(ch_no)
  #   wnseed.chaps.translate!(ch_no, ch_no)

  #   render json: chinfo
  # end

  # struct PatchForm
  #   include JSON::Serializable
  #   getter part_no : Int32
  #   getter line_no : Int32

  #   getter orig : String
  #   getter edit : String

  #   def after_initialize
  #     @orig = TextUtil.clean_spaces(@orig)
  #     @edit = TextUtil.clean_spaces(@edit)
  #   end
  # end

  # @[AC::Route::PATCH("/:ch_no", body: :form)]
  # def update_line(form : PatchForm, wn_id : Int32, sname : String, ch_no : Int32)
  #   guard_edit_privi wn_id: wn_id, sname: sname

  #   wnseed = get_wnseed(wn_id, sname)
  #   chinfo = get_chinfo(wnseed, ch_no)

  #   spawn do
  #     ChLineEdit.new(
  #       sname: wnseed.sname, s_bid: wnseed.s_bid,
  #       s_cid: chinfo.s_cid, ch_no: chinfo.ch_no,
  #       part_no: form.part_no, line_no: form.line_no,
  #       patch: form.edit, uname: _uname,
  #     ).insert!
  #   rescue ex
  #     Log.error(exception: ex) { ex.message.colorize.red }
  #   end

  #   chinfo.c_len += form.edit.size - form.orig.size

  #   if form.line_no == 0
  #     raise "input mismatch" if form.orig != chinfo.body[0]

  #     chinfo.body[0] = form.edit
  #   else
  #     ch_part = chinfo.body[form.part_no].lines
  #     line_no = form.line_no - 1
  #     raise "input mismatch" if form.orig != ch_part[line_no]

  #     ch_part[line_no] = form.edit
  #     chinfo.body[form.part_no] = ch_part.join('\n')
  #   end

  #   ztext = chinfo.body.join('\n')

  #   chinfo.save_body!(ztext, seed: wnseed, uname: _uname, _flag: 3)
  #   wnseed.update_stats!(ch_no)

  #   render json: chinfo
  # end
end
