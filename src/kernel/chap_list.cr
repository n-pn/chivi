require "colorize"
require "file_utils"
require "./chap_item"

class ChapList
  include BaseModel

  getter uuid : String
  getter seed : String

  property sbid = ""
  property type = 0

  getter chaps = [] of ChapItem
  getter index = {} of String => Int32 # manual sort

  forward_missing_to @chaps

  def initialize(@uuid : String, @seed : String)
    @changes = 1
  end

  def rebuild_index!
    @chaps.each_with_index { |item, idx| @index[item.scid] = idx }
  end

  def append(chap : ChapItem) : ChapItem
    @index[chap.scid] = @chaps.size
    @chaps.push(chap)
    chap
  end

  def upsert(chap : ChapItem, idx : Int32? = nil)
    upsert(chap.scid, idx, &.inherit(chap))
  end

  def upsert(scid : String, idx : Int32? = nil)
    if idx ||= @index[scid]?
      chap = @chaps[idx]
    else
      chap = append(ChapItem.new(scid))
    end

    yield chap
    @changes += chap.reset_changes!

    chap
  end

  def save!(file : String = ChapList.path_for(@uuid, @seed)) : Void
    ChapList.mkdir!(@uuid)
    File.write(file, to_json)

    puts "- <chap_list> [#{file.colorize.yellow}] saved \
            (changes: #{@changes.colorize.yellow})."
  end

  # class methods

  DIR = File.join("var", "chap_lists")
  FileUtils.mkdir_p(DIR)

  def self.mkdir!(uuid : String)
    FileUtils.mkdir_p(File.join(DIR, uuid))
  end

  def self.files(uuid : String = "**") : Array(String)
    Dir.glob(File.join(DIR, uuid, "*.json"))
  end

  def self.path_for(uuid : String, seed : String)
    File.join(DIR, uuid, "#{seed}.json")
  end

  def self.exists?(uuid : String, seed : String)
    File.exists?(path_for(uuid, seed))
  end

  def self.outdated?(uuid : String, seed : String, time : Time)
    file = path_for(uuid, seed)
    return true unless File.exists?(file)
    File.info(file).modification_time < time
  end

  def self.read!(file : String) : ChapList
    read(file) || raise "<chap_list> file [#{file}] not found!"
  end

  def self.read(file : String) : ChapList?
    return unless File.exists?(file)
    puts "- <chap_list> [#{file.colorize.blue}] loaded."
    from_json(File.read(file))
  end

  def self.load(uuid : String, seed : String) : ChapList?
    read(path_for(uuid, seed))
  end

  def self.load!(uuid : String, seed : String) : ChapList
    load(uuid, seed) || raise "<chap_list> list [#{uuid}/#{seed}] not found!"
  end

  def self.find_or_create(uuid : String, seed : String) : ChapList
    load(uuid, seed) || new(uuid, seed)
  end

  CACHE = {} of String => ChapList
  LIMIT = 500

  def self.cache_load!(uuid : String, seed : String) : ChapList
    cache_data("#{uuid}/#{seed}", load!(uuid, seed))
  end

  def self.cache_find_or_create(uuid : String, seed : String) : ChapList
    cache_data("#{uuid}/#{seed}", find_or_create(uuid, seed))
  end

  def self.cache_data(key : String, value : ChapList)
    CACHE.shift if CACHE.size > LIMIT
    CACHE[key] ||= value
  end

  def self.load_all!(uuid : String)
    ret = CACHE[uuid] ||= {} of String => ChapList

    files(uuid).each do |file|
      seed = File.basename(file, ".json")
      ret[seed] ||= load_file(file)
    end

    puts "- <chap_list> loaded [#{uuid}] chap lists to cache \
            (entries: #{ret.size.colorize.blue.bold})."

    ret
  end

  def self.find(uuid : String, seed : String, cache = true)
    unless list = CACHE[uuid][seed]?
      file = path_for(uuid, seed)
      return unless File.exists?(file)

      list = load_file(file)
      CACHE[uuid][seed] = list if cache
    end

    list
  end

  def self.find_or_create(uuid : String, seed : String, cache = true)
    unless list = find(uuid, seed, cache)
      list = new(uuid, seed)
      CACHE[uuid][seed] = list if cache
    end

    list
  end
end
