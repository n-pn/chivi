require "json"
require "../../appcv/zhtext/text_split"

class CV::ChtextCtrl < CV::BaseCtrl
  # upload batch text
  def upsert
    sname = params["sname"]
    guard_privi min: ACL.upsert_chtext(sname, _viuser.uname)

    chroot = load_chroot(sname, :auto)
    text, path = read_chtext(chroot)

    chinfos = split_chaps(chroot, path, text)

    if chinfos.size == 1 && (title = params["title"]?)
      chinfos.first.title = TextUtil.trim_spaces(title)
    end

    Chinfo.bulk_upsert(chinfos, cvmtl: chroot.nvinfo.cvmtl)
    update_chroot(chroot, chinfos.last, trunc: params["trunc_after"]? == "true")

    self_sname = '@' + _viuser.uname
    mirror_sname = chroot.sname == self_sname ? self_sname : "=user"
    mirror = Chroot.load!(chroot.nvinfo_id, mirror_sname, force: true)

    chmin, chmax = chinfos.first.chidx, chinfos.last.chidx
    mirror.mirror_other(chroot, chmin, chmax, chmin)
    serv_json({from: chmin, upto: chmax})
  end

  private def read_chtext(chroot : Chroot) : {String, String}
    save_dir = "var/chaps/users/#{chroot.sname}/#{chroot.snvid}"
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

  private def split_chaps(chroot : Chroot, path : String, text : String)
    options = read_options(chroot, self.params)
    splitter = Zhtext::Splitter.new(path, options, content: text)

    splitter.split!(options.split_mode)
    splitter.save_content!

    spawn splitter.save_chinfos!(uname: _viuser.uname)

    changed_at = Time.utc

    splitter.chapters.map do |input|
      Chinfo.new({
        chroot: chroot, viuser: _viuser, mirror_id: nil,
        chidx: input.chidx, schid: input.schid,
        title: input.title, chvol: input.chvol,
        w_count: input.w_count, p_count: input.p_count,
        changed_at: changed_at,
      })
    end
  end

  private def read_options(chroot : Chroot, params)
    Zhtext::Options.new do |x|
      x.init_chidx = params.read_i16("chidx", min: 1_i16)

      if chvol = params["chvol"]?
        x.init_chvol = TextUtil.trim_spaces(chvol)
      else
        x.init_chvol = "" # Chinfo.nearby_chvol(chroot, x.init_chidx)
      end

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

    Log.info { {chinfo.to_json, chinfo.mirror.try(&.to_json)} }
    chinfo = chinfo.mirror || chinfo

    zhtext = String.build do |io|
      0_i16.upto(chinfo.p_count &- 1_i16) do |cpart|
        ctext = chinfo.text(cpart, viuser: _viuser)
        cpart == 0 ? io << ctext : io << '\n' << ctext.sub(/.+?\n/, "")
      end
    end

    serv_json({chvol: chinfo.chvol, title: chinfo.title, input: zhtext})
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

    part_no = params.read_i16("cpart", min: 0_i16)
    line_no = params.read_i16("l_id", min: 0_i16)

    orig = params["orig"]?.try { |x| TextUtil.clean_spaces(x) }
    edit = TextUtil.clean_spaces(params["edit"])

    spawn do
      ChapEdit.new({
        viuser: _viuser, chroot: chroot,
        chidx: chinfo.chidx, schid: chinfo.schid,
        cpart: part_no, l_id: line_no,
        orig: orig, edit: edit, flag: 0_i16,
      }).save!
    end

    if mirror = chinfo.mirror
      chinfo.inherit(mirror)
      chinfo.mirror_id = nil
      chinfo.schid = "#{chinfo.chidx}_0"
    end

    content = [] of String
    chinfo.w_count &+= edit.size

    0_i16.upto(chinfo.p_count &- 1_i16) do |index|
      text = chinfo.text(index, viuser: _viuser)

      if index == part_no || line_no == 0
        lines = text.split('\n')
        chinfo.w_count &-= (orig || lines[line_no]).size

        lines[line_no] = edit
        text = lines.join('\n')
      end

      content << text
    end

    chinfo.changed_at = Time.utc
    chinfo.viuser = _viuser
    chinfo.save!

    ChPack.load(chroot, chinfo.chidx).save(chinfo.schid, content)

    serv_text("ok")
  end
end
