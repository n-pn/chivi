require "json"
require "colorize"
require "file_utils"

require "./chap_item"

# require "../_utils/text_utils"

class BookMeta
  include JSON::Serializable

  def add_seed(seed : String, sbid : String, type : Int32 = 0) : Void
    if @seed_lists.includes?(seed)
      return if @seed_sbids[seed] == sbid && @seed_types[seed] == type
    else
      @seed_lists << seed
    end

    @changed = true
    @seed_sbids[seed] = sbid
    @seed_types[seed] = type
    # rescue err
    # puts err
    # puts self
  end

  def set_type(seed : String, type : Int32 = 0) : Void
    return if @seed_types[seed]?.try(&.== type)
    @changed = true
    @seed_types[type] = type
  end

  def set_latest(seed : String, scid : String, title : String, mftime = 0_i64) : Void
    set_latest(seed, ChapItem.new(scid, title), mftime)
  end

  def set_latest(seed : String, chap : ChapItem, mftime = 0_i64)
    if old_chap = @latest_chaps[seed]?
      return if old_chap.scid == chap.scid

      mftime = @mftime if mftime < @mftime
      if mftime <= @latest_times.fetch(seed, 0)
        mftime = Time.utc.to_unix_ms
      end
    end

    @changed = true
    @latest_times[seed] = mftime
    @latest_chaps[seed] = chap
  end

  def to_s(io : IO)
    to_json(io)
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def save!(file : String = BookMeta.path_for(@uuid))
    mark_saved!

    File.write(file, self)
    puts "- <book_meta> [#{file.colorize(:cyan)}] saved."
  end

  # class methods

  DIR = File.join("var", "book_metas")
  FileUtils.mkdir_p(DIR)

  def self.uuid_for(file : String)
    File.basename(file, ".json")
  end

  def self.glob_dir
    Dir.glob(File.join(DIR, "*.json"))
  end

  def self.path_for(uuid : String)
    File.join(DIR, "#{uuid}.json")
  end

  def save!(seed : self, file = path_for(seed.uuid)) : Void
    seed.save!(file) if seed.changed?
  end

  def self.exist?(uuid : String)
    File.exists?(path_for(uuid))
  end

  def self.read_file(file : String)
    from_json(File.read(file))
  end

  def self.get(uuid : String, file = path_for(uuid))
    read_file(file) if File.exists?(file)
  end

  def self.get!(uuid : String) : self
    get(uuid) || raise "- <book_meta> [#{uuid}] not found!"
  end

  def self.get_or_create!(uuid : String) : self
    get(uuid) || new(uuid)
  end

  # Load with cache

  CACHE = {} of String => self

  def self.load_all!
    glob_dir.each { |file| load!(uuid_for(file)) }
    puts "- <book_meta> loaded `#{CACHE.size.colorize(:cyan)}` entries."

    CACHE
  end

  def self.load(uuid : String)
    load!(uuid) if File.exists?(path_for(uuid))
  end

  def self.load!(uuid : String)
    CACHE[uuid] ||= get!(uuid)
  end

  def self.load_or_create!(uuid : String)
    CACHE[uuid] ||= get_or_create!(uuid)
  end
end
