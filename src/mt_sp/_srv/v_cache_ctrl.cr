require "colorize"

require "./_sp_ctrl_base"

class SP::VcacheCtrl < AC::Base
  base "/_sp/vcache"

  TMP_DIR = "var/.keep/vcache"
  Dir.mkdir_p(TMP_DIR)

  @[AC::Route::POST("/:type")]
  def create(type : String)
    body = request.body.try(&.gets_to_end) || "{}"
    data = JSON.parse(body).as_h
    time = Time.utc

    data["_time"] = JSON::Any.new(time.to_unix)
    data["_user"] = JSON::Any.new(self._uname)

    out_path = "#{TMP_DIR}/#{time.to_s("%F")}-#{type}.jsonl"
    File.open(out_path, "a", &.puts(data.to_json))

    render text: "ok"
  rescue ex
    Log.error(exception: ex) { data }
    render text: ex.message
  end
end
