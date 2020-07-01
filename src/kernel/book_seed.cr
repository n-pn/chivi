require "json"
require "colorize"
require "file_utils"
require "./chap_item"

class BookSeed::Data
  include JSON::Serializable

  getter uuid = ""
  getter seed = ""

  property type = 0
  property sbid = ""

  property chaps_total = 0
  getter latest_chap = ChapItem.new

  def initialize(@uuid, @seed, @type = 0, @sbid = "")
  end

  def to_s(io : IO)
    to_json(io)
  end

  def remote?
    @type == 0
  end
end

module BookSeed
  extend self

  DIR = ::File.join("var", "appcv", "book_seeds")
  FileUtils.mkdir_p(DIR)

  def path(uuid : String, seed : String)
    ::File.join(DIR, "#{uuid}.#{seed}.json")
  end

  def init!(uuid : String, seed : String) : BookSeed::Data
    init(uuid, seed) || BookSeed::Data.new(uuid, seed)
  end

  def init(uuid : String, seed : String) : BookSeed::Data?
    file = path(uuid, seed)
    return unless ::File.exists?(file)
    BookSeed::Data.from_json(::File.read(file))
  end

  def save!(data : BookSeed::Data) : Void
    file = path(data.uuid, data.seed)
    ::File.write(file, data)
    # puts "- <book_seed> [#{file.colorize(:cyan)}] saved."
  end
end
