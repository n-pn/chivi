require "json"
require "sqlite3"

module YS::YsUtil
  extend self

  record Dict, dname : String, label : String do
    include DB::Serializable
  end

  DICTS = {} of Int32 => Dict

  def self.vdict(book_id : Int32)
    DICTS[book_id] ||= begin
      query = "select dname, label from dicts where id = ?"

      DB.open("sqlite3:var/dicts/v1raw/dicts_v1.db") do |db|
        db.query_one?(query, -book_id, as: Dict) || Dict.new("combine", "Tổng hợp")
      end
    end
  end

  def self.read_zip(zip_path : String, filename : String)
    read_zip?(zip_path, filename) || yield
  end

  def self.read_zip?(zip_path : String, filename : String)
    return unless File.exists?(zip_path)
    Compress::Zip::File.open(zip_path) do |zip|
      return unless entry = zip[filename]?
      entry.open(&.gets_to_end)
    end
  end

  def self.zipping(zip_path : String, inp_path : String)
    response = `zip -FS -jrq "#{zip_path}" "#{inp_path}"`
    raise response unless $?.success?
  end
end
