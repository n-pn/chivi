require "json"

class CV::ChtextCtrl < CV::BaseCtrl
  def zhtext
    raise Unauthorized.new("Quyền hạn không đủ!") if _viuser.privi < 1

    nvseed = load_nvseed
    chidx = params.read_i16("chidx", min: 1_i16)

    unless chinfo = nvseed.chinfo(chidx - 1)
      raise NotFound.new("Chương tiết không tồn tại")
    end

    set_headers content_type: :text

    response << "/// #{chinfo.chvol}\n#{chinfo.title}\n"
    response << '\n' << chinfo.text(0_i16)
    1_i16.upto(chinfo.p_count &- 1) do |cpart|
      text = chinfo.text(cpart)
      response << '\n' << text.sub(/.+?\n/, "")
    end
  end

  def upload
    return halt!(500, "Quyền hạn không đủ!") if _viuser.privi < 1
    nvseed = load_nvseed

    self_sname = "@" + _viuser.uname

    if (nvseed.sname != self_sname) && params["dup"]?
      target = nvseed
      nvinfo = target.nvinfo
      nvseed = Nvseed.load!(nvinfo, self_sname, force: true)
    end

    file_path = save_text(nvseed)
    success, from_chidx, message = invoke_splitter(nvseed, file_path)
    raise BadRequest.new(message) unless success

    last_chidx, last_schid = message.split('\t')
    last_chidx = last_chidx.to_i16

    spawn do
      trunc = params["trunc_after"]? == "true"
      update_nvseed(nvseed, last_chidx, last_schid, trunc: trunc)
      sync_changes(nvseed, from_chidx, last_chidx, target)
    end

    serv_json({from: from_chidx, upto: last_chidx})
  end

  private def save_text(nvseed : Nvseed) : String
    save_dir = "var/chseeds/#{nvseed.sname}/#{nvseed.snvid}"

    file_name = params["hash"]? || Time.local.to_unix.to_s(base: 32)
    file_path = File.join(save_dir, "#{file_name}.txt")
    Dir.mkdir_p(save_dir)

    if form_file = params.files["file"]?
      File.copy(form_file.file.path, file_path)
    elsif !(text = params["text"]?)
      raise BadRequest.new("Thiếu file hoặc text") unless File.exists?(file_path)
    elsif text.size < 30_000 || _viuser.privi > 1
      File.write(file_path, text)
    else
      raise BadRequest.new("Chương quá dài #{text.size} ký tự, tối đa: 30k ký tự")
    end

    file_path
  end

  private def update_nvseed(nvseed : Nvseed, last_chidx, last_schid, trunc = false)
    if last_chidx >= nvseed.chap_count || trunc
      nvseed.chap_count = last_chidx
      nvseed.last_schid = last_schid
    end

    nvseed.utime = Time.utc.to_unix
    nvseed.reset_cache!(raws: true)
    nvseed.save!
  end

  private def sync_changes(nvseed : Nvseed, chmin : Int16, chmax : Int16, target = Nvseed?)
    infos = nvseed._repo.clone!(chmin, chmax)

    if !target || target.sname[0]? == '@'
      user_seed = Nvseed.load!(nvseed.nvinfo, "=user", force: true)
      user_seed.patch_chaps!(infos, nvseed.utime, save: true)
    else
      target.patch_chaps!(infos, nvseed.utime, save: true)
    end
  end

  # -ameba:disable Metrics/CyclomaticComplexity
  private def invoke_splitter(nvseed : Nvseed, file_path : String) : {Bool, Int16, String}
    args = ["-i", file_path]
    args << "-u" << _viuser.uname
    params["chvol"]?.try { |x| args << "-v" << x.strip }

    from_chidx = params.read_i16("chidx", min: 1_i16)
    args << "-f" << from_chidx.to_s

    args << "--tosimp" if params["tosimp"]? == "true"
    args << "--unwrap" if params["unwrap"]? == "true"
    args << "-e" << "UTF-8"

    split_mode = params["split_mode"]? || "0"
    args << "-m" << split_mode
    add_args_for_split_mode(args, split_mode.to_i)

    output = IO::Memory.new
    status = Process.run("bin/text_split", args, output: output, error: output)
    output.close

    {status.success?, from_chidx, output.to_s.strip}
  end

  private def add_args_for_split_mode(args : Array(String), split_mode : Int32)
    case split_mode
    when 1
      args << "--trim" if params["trim_space"]? == "true"
      params["min_blank"]?.try { |x| args << "--min-blank" << x }
    when 2
      args << "--blank-before" if params["blank_before"]? == "true"
    when 3
      params["suffix"]?.try { |x| args << "--suffix" << x.strip }
    when 4
      params["regex"]?.try { |x| args << "--regex" << x.strip }
    end
  end

  def change
    return halt!(500, "Quyền hạn không đủ!") if _viuser.privi < 1
    nvseed = load_nvseed

    chidx = params.read_i16("chidx", min: 1_i16)
    cpart = params.read_i16("cpart", min: 0_i16)

    unless chinfo = nvseed.chinfo(chidx &- 1)
      raise NotFound.new("Chương tiết không tồn tại")
    end

    l_id = params.read_i16("l_id", min: 1_i16)
    orig = params["orig"]?
    edit = params["edit"]

    spawn do
      ChapEdit.new({
        viuser: _viuser, chroot: nvseed,
        chidx: chidx, schid: chinfo.schid, cpart: cpart,
        l_id: l_id, orig: orig, edit: edit, flag: 0_i16,
      }).save!
    end

    parts = [] of String

    chinfo.p_count.times do |index|
      text = chinfo.text(index.to_i16, redo: false, viuser: _viuser)
      if index == cpart
        lines = text.split('\n')

        chinfo.w_count &+= edit.size
        chinfo.w_count &-= (orig || lines[l_id]?).try(&.size) || 0

        lines[l_id] = text
        text = lines.join('\n')
      end

      parts << text
    end

    chinfo.parts = parts
    chinfo.mirror_id = nil
    chinfo.changed_at = Time.utc

    chinfo.viuser = _viuser
    chinfo.save!

    serv_text("ok")
  end
end
