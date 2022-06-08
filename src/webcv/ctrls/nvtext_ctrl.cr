require "json"

class CV::NvtextCtrl < CV::BaseCtrl
  # UPLOAD_DIR = "var/chseeds/"

  # class UploadInfos
  #   include JSON::Serializable

  #   getter uname : String
  #   getter bname : String
  #   getter bslug : String
  #   getter sname : String
  #   getter snvid : String
  #   getter chidx : Int32 = 1
  #   getter _trad : Bool = false

  #   def initialize(@uname, @bname, @bslug, @sname, @snvid, @chidx, @_trad)
  #   end
  # end

  DIR = "/@%s/%s"

  def upload
    return halt!(500, "Quyền hạn không đủ!") if _cvuser.privi < 2

    sname = "@" + _cvuser.uname
    nvseed = Nvseed.load!(params["book"].to_i64, sname, force: true)

    entry = UkeyUtil.encode32(Time.local.to_unix)

    spawn do
      folder = "var/chtexts/#{sname}/#{nvseed.snvid}/_"
      file_path = File.join(folder, "#{entry}.txt")

      Dir.mkdir_p(folder)
      persist_to_disk(file_path)
      invoke_splitter(nvseed, file_path)
    end

    serv_json({entry: entry})
  end

  def persist_to_disk(file_path : String) : Nil
    if form_file = params.files["file"]?
      `mv #{form_file.file.path} #{file_path}`
    elsif text = params["text"]?
      File.write(file_path, text)
    else
      raise BadRequest.new("Thiếu file hoặc text")
    end
  end

  # -ameba:disable Metrics/CyclomaticComplexity
  def invoke_splitter(nvseed : Nvseed, file_path : String) : Nil
    args = ["-i", file_path]
    args << "--simp" if params["_trad"]? == "true"
    args << "--fix-wrap" if params["fix_wrap"]? == "true"
    params["encoding"]?.try { |x| args << "-e" << x unless x == "auto" }

    args << "-u" << _cvuser.uname
    params["chvol"]?.try { |x| args << "-v" << x.strip }

    from_chidx = params.fetch_int("chidx", min: 1)
    args << "-f" << from_chidx.to_s

    split_mode = params["split_mode"]? || "1"
    args << "-m" << split_mode
    add_args_for_split_mode(args, split_mode.to_i)

    output = IO::Memory.new
    status = Process.run("bin/split_text", args, output: output)

    output.close
    return unless status.success?

    last_chidx, last_schid = output.to_s.split('\t')
    last_chidx = last_chidx.to_i

    if last_chidx > nvseed.chap_count
      nvseed.chap_count = last_chidx
      nvseed.last_schid = last_schid
    end

    nvseed.utime = Time.utc.to_unix
    nvseed.save!

    # TODO: pinpoint clear cache
    nvseed.reset_cache!
    QtranData.clear_cache("chaps", disk: true)
    `curl -X DELETE localhost:5502/_v2/purge/chaps`
  end

  private def add_args_for_split_mode(args : Array(String), split_mode : Int32)
    case split_mode
    when 2
      args << "--trim" if params["trim_space"]? == "true"
      params["min_blank"]?.try { |x| args << "--min-blank" << x }
    when 3
      args << "--blank-before" if params["require_blank"]? == "true"
    when 4
      params["suffix"]?.try { |x| args << "--suffix" << x.strip }
    when 5
      params["regex"]?.try { |x| args << "--regex" << x.strip }
    end
  end
end
