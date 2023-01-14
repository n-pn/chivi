require "compress/zip"
require "../../_util/hash_util"
require "../../_util/tran_util"
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

struct Base32ID
  # i.e. `"master#742887"`
  def convert(raw : String)
    HashUtil.decode32(raw)
  end
end
