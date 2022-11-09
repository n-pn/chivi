require "compress/zip"
require "../../_util/ukey_util"
require "../../appcv/ys_book"

# require "../../appcv/shared/book_util"

module YS::Helpers
  record Dict, name : String, label : String do
    include DB::Serializable
  end

  DICTS = {} of Int32 => Dict

  def self.load_dict(book_id : Int32)
    DICTS[book_id] ||= begin
      query = "select name, label from dicts where id = ?"

      DB.open("sqlite3://var/dicts/index.db") do |db|
        db.query_one(query, args: [-book_id], as: Dict)
      rescue
        Dict.new("combine", "Tổng hợp")
      end
    end
  end

  def self.read_zip(zip_path : String, file_name : String)
    Compress::Zip::File.open(zip_path) do |zip|
      zip[file_name]?.try(&.open(&.gets_to_end)) || yield
    end
  end

  HEADERS = HTTP::Headers{"content-type" => "application/json"}

  def self.qtran(input : String, dname : String)
    url = "http://localhost:5010/api/qtran"
    body = {input: input, dname: dname, mode: "plain"}.to_json

    HTTP::Client.post(url, headers: HEADERS, body: body) do |res|
      return res.body_io.gets_to_end if res.status.success?
      Log.error { "error: #{res.body}" }
    end
  rescue err
    Log.error(exception: err) { err.message }
  end
end
