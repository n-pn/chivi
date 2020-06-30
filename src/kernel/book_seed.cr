require "json"
require "colorize"
require "file_utils"
require "./chap_item"

class BookSeed::Data
  include JSON::Serializable

  property uuid = ""
  property seed = ""
  property sbid = ""
  property type = 0
  # types: 0 => remote, 1 => manual, 2 => locked

  property chaps_count = 0
  property latest_chap = ChapItem.new

  def initialize(@uuid, @seed, @sbid = "", @type = 0)
  end

  def to_s(io : IO)
    to_json(io)
  end

  def remote?
    @type == 0
  end
end

module BookSeed::Repo
  extend self

  DIR = File.join("var", "appcv", "book_seeds")

  def mkdir!
    FileUtils.mkdir_p(DIR)
  end

  def clear!
    FileUtils.rm_rf(DIR)
    mkdir!
  end

  def path(uuid : String, seed : String)
    File.join(DIR, "#{uuid}.#{seed}.json")
  end

  def load!(uuid : String, seed : String)
    BookSeed::Data
    load(uuid, seed) || BookSeed::Data.new(uuid, seed)
  end

  def load(uuid : String, seed : String) : BookSeed::Data?
    file = path(uuid, seed)
    return unless File.exists?(file)
    BookSeed::Data.from_json(File.read(file))
  end

  def save!(data : BookSeed::Data) : Void
    file = path(data.uuid, data.seed)
    File.write(file, data)
    # puts "- <book_seed> [#{file.colorize(:cyan)}] saved."
  end
end
