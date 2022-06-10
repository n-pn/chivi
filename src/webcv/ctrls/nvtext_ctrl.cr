require "json"

class CV::NvtextCtrl < CV::BaseCtrl
  def upload
    return halt!(500, "Quyền hạn không đủ!") if _cvuser.privi < 2

    sname = "@" + _cvuser.uname
    nvseed = Nvseed.load!(params["book"].to_i64, sname, force: true)

    save_dir = "var/chseeds/#{nvseed.sname}/#{nvseed.snvid}"
    Dir.mkdir_p(save_dir)

    file_name = params["hash"]? || Time.local.to_unix.to_s(base: 32)
    file_path = File.join(save_dir, "#{file_name}.txt")
    persist_to_disk(file_path)

    success, message = invoke_splitter(nvseed, file_path)
    raise BadRequest.new(message) unless success

    last_chidx, last_schid = message.split('\t')
    last_chidx = last_chidx.to_i

    if last_chidx > nvseed.chap_count || params["trunc_after"]? == "true"
      nvseed.chap_count = last_chidx
      nvseed.last_schid = last_schid
    end

    nvseed.utime = Time.utc.to_unix
    nvseed.save!

    # TODO: pinpoint clear cache
    nvseed.reset_cache!
    QtranData.clear_cache("chaps", disk: true)
    HTTP::Client.delete("localhost:5502/_v2/purge/chaps")

    serv_json({msg: "ok"})
  end

  private def persist_to_disk(file_path : String) : Nil
    if form_file = params.files["file"]?
      File.copy(form_file.file.path, file_path)
    elsif text = params["text"]?
      File.write(file_path, text)
    else
      raise BadRequest.new("Thiếu file hoặc text") unless File.exists?(file_path)
    end
  end

  # -ameba:disable Metrics/CyclomaticComplexity
  private def invoke_splitter(nvseed : Nvseed, file_path : String) : {Bool, String}
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

    {status.success?, output.to_s}
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
