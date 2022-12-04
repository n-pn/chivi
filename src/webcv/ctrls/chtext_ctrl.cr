require "json"
require "../../zhlib/models/ch_edit"

class CV::ChtextCtrl < CV::BaseCtrl
  # upload batch text
  def upsert
    sname = params["sname"]
    guard_privi min: ACL.upsert_chtext(sname, _viuser.uname)

    chroot = load_chroot(sname, :auto)

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

    serv_json({from: chmin, upto: chmax})
  end

  private def save_upload_text(chroot : Chroot) : String
    save_dir = "var/chaps/users/#{chroot.sname}"
    Dir.mkdir_p(save_dir)

    file_hash = params["hash"]? || Time.utc.to_unix.to_s(base: 32)
    file_path = "#{save_dir}/#{chroot.s_bid}-#{file_hash}.txt"

    if form_file = params.files["file"]?
      File.copy(form_file.file.path, file_path)
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
      res = `./bin/trad2sim -i "#{txt_path}" -o #{fix_path}`
      raise BadRequest.new(res) unless $?.success?
      txt_path = fix_path
    end

    if params["unwrap"]? == "true"
      res = `./bin/fix_text -i "#{txt_path}" -o #{fix_path}`
      raise BadRequest.new(res) unless $?.success?
      txt_path = fix_path
    end

    txt_path
  end

  private def save_split_args(chroot : Chroot, txt_path : String) : Nil
    arg_path = txt_path.sub(".txt", ".arg")
    arg_file = File.open(arg_path, "w")

    ch_no = params.read_int("chidx", min: 1)
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

  def rawtxt
    guard_privi min: 1

    chroot = load_chroot
    chinfo = load_chinfo(chroot)

    input = String.build do |io|
      mode = chroot.is_remote ? 1_i8 : 0_i8
      texts = chinfo.all_text(mode: mode, uname: _viuser.uname)
      io << texts.shift?
      texts.each { |text| io << text.split('\n', 2).last }
    end

    serv_json({chvol: chinfo.chvol, title: chinfo.title, input: input})
  end

  private def update_chroot(chroot : Chroot, chinfo : Chinfo, trunc = false)
    chroot.set_latest(chinfo, force: trunc)
    chroot.stime = chroot.utime = Time.utc.to_unix
    chroot.save!
  end

  def change
    sname = params["sname"]
    guard_privi min: ACL.upsert_chtext(sname, _viuser.uname)

    chroot = load_chroot(sname, :find)
    chinfo = load_chinfo(chroot)

    part_no = params.read_i16("part_no", min: 0_i16)
    line_no = params.read_i16("line_no", min: 0_i16)

    orig = TextUtil.clean_spaces(params["orig"]? || "")
    edit = TextUtil.clean_spaces(params["edit"])

    ZH::LineEdit.new(
      uname: _viuser.uname, sname: chroot.sname,
      s_bid: chroot.s_bid, s_cid: chinfo.s_cid,
      ch_no: chinfo.ch_no.not_nil!, cpart: part_no,
      l_id: line_no, orig: orig, edit: edit
    ).create!

    content = chinfo.all_text(mode: 0, uname: _viuser.uname)

    chinfo.c_len &+= edit.size &- orig.size if line_no > 0
    chinfo.p_len = content.size

    content.each_with_index do |part_text, idx|
      next unless idx == part_no || line_no == 0
      content[idx] = part_text.split('\n').tap(&.[line_no] = edit).join('\n')
    end

    chinfo.change_root!(chroot) if chinfo.sn_id != chroot._repo.sn_id
    chinfo.save_text(content, uname: _viuser.uname)
    chroot._repo.upsert(chinfo)
    chroot.clear_cache!

    serv_text({chroot.sname, chroot.s_bid, chinfo.ch_no, part_no}.join(":"))
  end
end
