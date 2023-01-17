require "../_ctrl_base"
require "../../../zhlib/models/line_edit"
require "../../../zhlib/models/text_edit"
require "../../../_util/diff_util"

class CV::ChtextCtrl < CV::BaseCtrl
  base "/api/texts/:book_id/:sname"

  getter! nvinfo : Nvinfo
  getter! chroot : Chroot
  getter! chinfo : Chinfo

  @[AC::Route::Filter(:before_action)]
  def load_resources(book_id : Int64, sname : String, ch_no : Int32?)
    @chroot = get_chroot(book_id, sname)
    @chinfo = get_chinfo(chroot, ch_no) if ch_no
  end

  # upload batch text
  @[AC::Route::PUT("/")]
  def upsert
    guard_privi min: 1

    txt_path = save_upload_text(chroot)
    tsv_path = split_chap_texts(chroot, txt_path)

    infos = chroot._repo.read_file(tsv_path).values.sort_by!(&.ch_no.not_nil!)

    if infos.size == 1 && (title = params["title"]?)
      infos.first.title = TextUtil.trim_spaces(title)
    end

    chroot._repo.bulk_upsert(infos)
    chroot.clear_cache!

    update_chroot(chroot, infos.last, trunc: params["trunc_after"]? == "true")

    chmin = infos.first.ch_no!
    chmax = infos.last.ch_no!

    spawn do
      self_sname = '@' + _viuser.uname
      mirror_sname = chroot.sname == self_sname ? self_sname : "=user"

      mirror = Chroot.load!(chroot.nvinfo_id, mirror_sname, force: true)
      mirror.mirror_other!(chroot, chmin, chmax, chmin)
    end

    render json: {from: chmin, upto: chmax}
  end

  private def save_upload_text(chroot : Chroot) : String
    save_dir = "var/chaps/users/#{chroot.sname}"
    Dir.mkdir_p(save_dir)

    file_hash = params["hash"]? || Time.utc.to_unix.to_s(base: 32)
    file_path = "#{save_dir}/#{chroot.s_bid}-#{file_hash}.txt"

    if form_file = files.try(&.["file"]?.try(&.[0]))
      File.write(file_path, form_file.body)
      return file_path
    end

    unless text = params["text"]?
      return file_path if File.exists?(file_path)
      raise BadRequest.new("Thiếu file hoặc text")
    end

    if _viuser.privi < 2 && text.size > 40_000
      raise BadRequest.new("Chương quá dài: #{text.size}/40_000 ký tự")
    end

    File.write(file_path, text)
    file_path
  end

  private def split_chap_texts(chroot : Chroot, txt_path : String) : String
    txt_path = fix_text_input(txt_path)
    save_split_args(chroot, txt_path)

    res = `./bin/text_split "#{txt_path}" #{_viuser.uname}`
    raise BadRequest.new(res.strip) unless $?.success?

    txt_path.sub(".txt", ".tsv")
  end

  private def fix_text_input(txt_path : String)
    fix_path = txt_path.sub(".txt", ".fix.txt")

    if params["tosimp"]? == "true"
      res = `/usr/bin/opencc -c tw2c -i "#{txt_path}" -o "#{fix_path}"`
      raise BadRequest.new(res) unless $?.success?
      txt_path = fix_path
    end

    if params["unwrap"]? == "true"
      res = `./bin/fix_text -i "#{txt_path}" -o "#{fix_path}"`
      raise BadRequest.new(res) unless $?.success?
      txt_path = fix_path
    end

    txt_path
  end

  private def save_split_args(chroot : Chroot, txt_path : String) : Nil
    arg_path = txt_path.sub(".txt", ".arg")
    arg_file = File.open(arg_path, "w")

    ch_no = params["chidx"].to_i
    save_arg(arg_file, "init_ch_no", ch_no, &.> 1)

    chvol = params["chvol"]? || chroot._repo.nearby_chvol(ch_no)
    save_arg(arg_file, "init_chvol", chvol, &.empty?.!)

    split_mode = params["split_mode"].to_i
    save_arg(arg_file, "split_mode", split_mode)

    case split_mode
    when 0
      min_repeat = params["min_repeat"]?.try(&.to_i?)
      save_arg(arg_file, "min_repeat", min_repeat) { min_repeat && min_repeat != 3 }
    when 1
      trim_space = params["trim_space"]? == "true"
      save_arg(arg_file, "trim_space", trim_space)

      min_blanks = params["min_blanks"]?.try(&.to_i?)
      save_arg(arg_file, "min_blanks", min_blanks)
    when 2
      need_blank = params["need_blank"]? == "true"
      save_arg(arg_file, "need_blank", need_blank)
    when 3
      title_suffix = params["label"]?
      save_arg(arg_file, "title_suffix", title_suffix)
    when 4
      custom_regex = params["regex"]?
      save_arg(arg_file, "custom_regex", custom_regex)
    end

    arg_file.close
  end

  private def save_arg(io : IO, key : String, val)
    save_arg(io, key, val) { val }
  end

  private def save_arg(io : IO, key : String, val)
    io << key << '\t' << val << '\n' if yield val
  end

  @[AC::Route::GET("/:ch_no")]
  def rawtxt
    guard_privi min: 1
    render json: {chvol: chinfo.chvol, title: chinfo.title, input: chinfo.full_body}
  end

  private def update_chroot(chroot : Chroot, chinfo : Chinfo, trunc = false)
    chroot.set_latest(chinfo, force: trunc)
    chroot.stime = chroot.utime = Time.utc.to_unix
    chroot.save!
  end

  struct TextForm
    include JSON::Serializable

    getter input : String
    getter chvol : String
    getter title : String

    def after_initialize
      @input = TextUtil.clean_spaces(@input)
      @chvol = TextUtil.clean_spaces(@chvol)
      @title = TextUtil.clean_spaces(@title)
    end
  end

  @[AC::Route::PUT("/:ch_no", body: :form)]
  def update(form : TextForm)
    guard_privi min: 1

    chinfo.chvol = form.chvol
    chinfo.title = form.title
    chinfo.save_body(form.input, uname: _viuser.uname)

    chroot._repo.upsert(chinfo)
    chroot.clear_cache!

    spawn create_text_edit(chroot, chinfo, form.input)
    render json: {msg: "ok"}
  end

  private def create_text_edit(chroot, chinfo, new_ztext)
    ZH::TextEdit.new({
      sname: chroot.sname,
      s_bid: chroot.s_bid,
      s_cid: chinfo.s_cid,
      ch_no: chinfo.ch_no!,
      patch: DiffUtil.diff_json(chinfo.full_body, new_ztext),
      uname: _viuser.uname,
    }).save!
  end

  struct LineForm
    include JSON::Serializable
    getter part_no : Int32, line_no : Int32
    getter edit : String, orig : String = ""

    def after_initialize
      @orig = TextUtil.clean_spaces(@orig)
      @edit = TextUtil.clean_spaces(@edit)
    end
  end

  @[AC::Route::PATCH("/:ch_no", body: :form)]
  def change(form : LineForm)
    guard_privi min: 1

    spawn create_line_edit(chroot, chinfo, form)

    content = chinfo.body_parts(mode: 0, uname: _viuser.uname)

    chinfo.c_len &+= form.edit.size &- form.orig.size if form.line_no > 0
    chinfo.p_len = content.size

    content.each_with_index do |part_text, idx|
      next unless idx == form.part_no || form.line_no == 0
      content[idx] = part_text.split('\n').tap(&.[form.line_no] = form.edit).join('\n')
    end

    chinfo.change_root!(chroot) if chinfo.sn_id != chroot._repo.sn_id
    chinfo.save_text(content, uname: _viuser.uname)
    chroot._repo.upsert(chinfo)
    chroot.clear_cache!

    rl_key = {chroot.sname, chroot.s_bid, chinfo.ch_no, form.part_no}.join(':')
    render text: rl_key
  end

  private def create_line_edit(chroot, chinfo, form)
    ZH::LineEdit.new({
      sname: chroot.sname, s_bid: chroot.s_bid,
      s_cid: chinfo.s_cid, ch_no: chinfo.ch_no!,
      part_no: form.part_no, line_no: form.line_no,
      patch: DiffUtil.diff_json(form.orig, form.edit),
      uname: _viuser.uname,
    }).save!
  end
end
