require "json"

class CV::NvtextCtrl < CV::BaseCtrl
  private def load_nvseed
    nvinfo_id = params["book"].to_i64
    sname = params.fetch_str("sname", "union")
    Nvseed.load!(nvinfo_id, SnameMap.map_int(sname))
  end

  UPLOAD_DIR = "var/chseeds/"

  class UploadInfos
    include JSON::Serializable

    getter uname : String
    getter bname : String
    getter bslug : String
    getter sname : String
    getter snvid : String
    getter chidx : Int32 = 1
    getter _trad : Bool = false

    def initialize(@uname, @bname, @bslug, @sname, @snvid, @chidx, @_trad)
    end
  end

  def upload
    return halt!(500, "Quyền hạn không đủ!") if _cvuser.privi < 2

    nvseed = load_nvseed
    nvinfo = nvseed.nvinfo

    entry_name = UkeyUtil.encode32(Time.local.to_unix.unsafe_shl(10) &+ _cvuser.id)

    entry_folder = File.join(UPLOAD_DIR, entry_name)
    Dir.mkdir_p(entry_folder)

    entry_path = File.join(entry_folder, "input.txt")

    if form_file = params.files["file"]?
      status = `mv #{form_file.file.path} #{entry_path}`
      raise status unless $?.success?
    elsif text = params["text"]?
      File.write(entry_path, text)
    else
      raise BadRequest.new("Thiếu file hoặc text")
    end

    chidx = params.fetch_int("chidx")
    _trad = params["_trad"]? == true

    infos = UploadInfos.new(
      uname: _cvuser.uname,
      bname: nvinfo.vname,
      bslug: nvinfo.bslug,
      sname: nvseed.sname,
      snvid: nvseed.snvid,
      chidx: chidx,
      _trad: _trad
    )

    File.write(File.join(entry_folder, "info.json"), infos.to_pretty_json)
    serv_json({entry: entry_name})
  end

  def status
    entry_name = params["entry"]
    entry_folder = File.join(UPLOAD_DIR, entry_name)

    infos_path = File.join(entry_folder, "info.json")
    state_path = File.join(entry_folder, "state.txt")

    upload_infos = UploadInfos.from_json File.read(infos_path)

    serv_json({
      infos: upload_infos,
      state: File.exists?(state_path) ? File.read(state_path) : "",
    })
  end
end
