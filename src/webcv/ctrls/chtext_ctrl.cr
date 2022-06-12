require "json"

class CV::ChtextCtrl < CV::BaseCtrl
  private def load_nvseed(sname = params["sname"], force : Bool = false)
    snvid = params["snvid"]

    Nvseed.find({sname: sname, snvid: snvid}) || begin
      unless nvinfo = Nvinfo.find({bhash: snvid})
        raise NotFound.new("Quyển sách không tồn tại")
      end

      Nvseed.load!(nvinfo, sname, force: true)
    end
  end

  def zhtext
    raise Unauthorized.new("Quyền hạn không đủ!") if _cvuser.privi < 1

    nvseed = load_nvseed(force: false)
    chidx = params.fetch_int("chidx", min: 1)

    unless chinfo = nvseed.chinfo(chidx - 1)
      raise NotFound.new("Chương tiết không tồn tại")
    end

    set_headers content_type: :text

    response << "/// #{chinfo.chvol}\n#{chinfo.title}\n"

    chinfo.stats.parts.times do |cpart|
      lines = nvseed.chtext(chinfo, cpart)
      1.upto(lines.size - 1) { |i| response << '\n' << lines.unsafe_fetch(i) }
    end
  end

  def upload
    return halt!(500, "Quyền hạn không đủ!") if _cvuser.privi < 1
    nvseed = load_nvseed("@#{_cvuser.uname}", force: true)

    file_path = save_text(nvseed)
    success, from_chidx, message = invoke_splitter(nvseed, file_path)
    raise BadRequest.new(message) unless success

    last_chidx, last_schid = message.split('\t')
    last_chidx = last_chidx.to_i

    trunc = params["trunc_after"]? == "true"
    update_nvseed(nvseed, last_chidx, last_schid, trunc: trunc)
    clear_cache(nvseed, from_chidx, last_chidx)

    nvseed.reset_cache!

    serv_json({from: from_chidx, upto: last_chidx})
  end

  # def upsert
  #   return halt!(500, "Quyền hạn không đủ!") if _cvuser.privi < 1

  #   orig_seed = load_nvseed(force: false)
  #   self_name = "@#{_cvuser.uname}"

  #   if orig_seed.sname != self_name
  #     self_seed = Nvseed.load!(orig_seed.nvinfo, self_name)
  #   else
  #     self_seed = orig_seed
  #   end

  #   file_path = save_text(self_nvseed, bulk: false)
  #   success, from_chidx, message = invoke_splitter(self_nvseed, file_path)
  #   raise BadRequest.new(message) unless success
  # end

  private def save_text(nvseed : Nvseed) : String
    save_dir = "var/chseeds/#{nvseed.sname}/#{nvseed.snvid}"

    file_name = params["hash"]? || Time.local.to_unix.to_s(base: 32)
    file_path = File.join(save_dir, "#{file_name}.txt")
    Dir.mkdir_p(save_dir)

    if form_file = params.files["file"]?
      File.copy(form_file.file.path, file_path)
    elsif !(text = params["text"]?)
      raise BadRequest.new("Thiếu file hoặc text") unless File.exists?(file_path)
    elsif text.size < 30_000 || _cvuser.privi > 1
      File.write(file_path, text)
    else
      raise BadRequest.new("Chương quá dài #{text.size} ký tự, tối đa: 30k ký tự")
    end

    file_path
  end

  private def update_nvseed(nvseed : Nvseed, last_chidx, last_schid, trunc = false)
    if last_chidx > nvseed.chap_count || trunc
      nvseed.chap_count = last_chidx
      nvseed.last_schid = last_schid
    end

    nvseed.utime = Time.utc.to_unix
    nvseed.save!
  end

  private def clear_cache(nvseed, from_chidx : Int32, upto_chidx : Int32)
    # TODO: pinpoint clear cache
    QtranData.clear_cache("chaps", disk: true)
    spawn HTTP::Client.delete("localhost:5502/_v2/purge/chaps")
  rescue err
    puts err
  end

  # -ameba:disable Metrics/CyclomaticComplexity
  private def invoke_splitter(nvseed : Nvseed, file_path : String) : {Bool, Int32, String}
    args = ["-i", file_path]
    args << "-u" << _cvuser.uname
    params["chvol"]?.try { |x| args << "-v" << x.strip }

    from_chidx = params.fetch_int("chidx", min: 1)
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

    {status.success?, from_chidx, output.to_s}
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
end
