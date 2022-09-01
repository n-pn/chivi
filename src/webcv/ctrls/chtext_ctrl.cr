require "json"
require "../../appcv/zhtext/text_split"

class CV::ChtextCtrl < CV::BaseCtrl
  # upload batch text
  def upsert
    sname = params["sname"]
    guard_privi min: ACL.upsert_chtext(sname, _viuser.uname)

    chroot = load_chroot(sname, :auto)
    text, path = read_chtext(chroot)

    infos = split_chaps(chroot, path, text)

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

  private def read_chtext(chroot : Chroot) : {String, String}
    save_dir = "var/chaps/users/#{chroot.sname}/#{chroot.s_bid}"
    Dir.mkdir_p(save_dir)

    name = params["hash"]? || Time.local.to_unix.to_s(base: 32)
    path = File.join(save_dir, name + ".txt")

    if form_file = params.files["file"]?
      File.copy(form_file.file.path, path)
      return {File.read(path), path}
    end

    if !(text = params["text"]?)
      raise BadRequest.new("Thiếu file hoặc text") unless File.exists?(path)
      text = File.read(path)
    elsif _viuser.privi < 2 && text.size > 40_000
      raise BadRequest.new("Chương quá dài: #{text.size}/40_000 ký tự")
    end

    spawn File.write(path, text)
    {text, path}
  end

  private def split_chaps(chroot : Chroot, path : String, text : String) : Array(Chinfo)
    options = read_options(chroot, self.params)
    splitter = Zhtext::Splitter.new(path, options, content: text)

    splitter.split!(options.split_mode)
    splitter.save_content!

    sn_id = chroot._repo.sn_id
    s_bid = chroot.s_bid
    uname = _viuser.uname
    utime = Time.utc.to_unix

    spawn splitter.save_chinfos!(uname: uname)

    splitter.chapters.map do |input|
      Chinfo.new({
        sn_id: sn_id, s_bid: s_bid,
        ch_no: input.ch_no, s_cid: input.ch_no,
        title: input.title, chvol: input.chvol,
        c_len: input.c_len, p_len: input.p_len,
        utime: utime, uname: uname,
      })
    end
  end

  private def read_options(chroot : Chroot, params)
    Zhtext::Options.new do |x|
      x.init_ch_no = params.read_int("chidx", min: 1)
      x.init_chvol = params["chvol"]?.try { |s| TextUtil.trim_spaces(s) } || ""

      x.to_simp = params["tosimp"]? == "true"
      x.un_wrap = params["unwrap"]? == "true"

      x.encoding = params["encoding"]? || "UTF-8"
      x.split_mode = params["split_mode"].to_i

      case x.split_mode
      when 0
        x.repeating = params["repeating"]?.try(&.to_i) || 3
      when 1
        x.trim_space = params["trim_space"]? == "true"
        x.min_blanks = params["min_blanks"]?.try(&.to_i?) || 2
      when 2
        x.need_blank = params["need_blank"]? == "true"
      when 3
        params["label"]?.try { |r| x.title_suffix = r.strip }
      when 4
        params["regex"]?.try { |r| x.custom_regex = r.strip }
      end
    end
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

    spawn do
      ChapEdit.new({
        viuser: _viuser, chroot: chroot,
        chidx: chinfo.ch_no, schid: chinfo.s_cid,
        cpart: part_no, l_id: line_no,
        orig: orig, edit: edit, flag: 0_i16,
      }).save!
    end

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
