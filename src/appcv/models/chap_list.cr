require "colorize"
require "file_utils"

require "./chap_info"

class ChapList
  include JsonData

  getter ubid : String # book ubid
  getter seed : String # seed name
  property sbid = ""   # seed book id

  getter chaps = [] of ChapInfo
  getter index = {} of String => Int32 # can be used for manual sort

  # TODO: explicit adding `delegate` calls for better error checking
  delegate size, to: @chaps

  # forward_missing_to @chaps

  def initialize(@ubid : String, @seed : String)
    @changes = 1
  end

  # should not be used
  def rebuild_index!
    @chaps.each_with_index { |item, idx| @index[item.scid] = idx }
  end

  # check if this version of chap list is matched with updated list
  def match?(items : Array(ChapInfo))
    rebuild_index! if @index.empty?

    @index.each do |scid, idx|
      # check if old item existed in new list
      return false unless chap = @items[idx]?
      # check if chap link changed
      return false if chap.scid != scid
    end

    true
  end

  # merge self with a list of items, make full assignments if `dirty` == false
  def merge!(source : Array(ChapInfo), dirty : Bool = true)
    size = source.size
    truncate!(size) if @chaps.size > size

    @chaps.size.times do |idx|
      old_chap = @chaps[idx]
      new_chap = source[idx]

      if old_chap.scid == new_chap.scid
        next if dirty
      else
        @index.delete(old_chap.scid)
        @index[new_chap.scid] = idx
        old_chap.scid = new_chap.scid
      end

      old_chap.inherit(new_chap, force: true)
      @changes += old_chap.reset_changes!
    end

    @chaps.size.upto(size - 1) do |idx|
      append(source.unsafe_fetch(idx))
    end
  end

  # delete chap_info at `idx` position and update @index
  def delete_at!(idx : Int32)
    if chap = @chaps.delete_at(idx)
      @index.delete(chap.scid)

      idx.upto(@chaps.size - 1) do |jdx|
        @index[@chaps.unsafe_fetch(jdx).scid] = jdx
        @changes += 1
      end
    end
  end

  # remove extra chap_items
  def truncate!(from : Int32 = 0)
    (@chaps.size - from).times do
      @changes += 1
      last = @chaps.pop
      @index.delete(last.scid)
    end
  end

  # add a new chap_info to last position
  def append(chap : ChapInfo) : ChapInfo
    @index[chap.scid] = @chaps.size
    @chaps.push(chap)
    chap
  end

  def update_each
    @chaps.each do |chap|
      chap = yield(chap)
      @changes += chap.reset_changes!
    end
  end

  # insert or update a chap_info
  def upsert(chap : ChapInfo, idx : Int32? = nil)
    upsert(chap.scid, idx, &.inherit(chap))
  end

  # insert or update a chap_info with block
  def upsert(scid : String, idx : Int32? = nil)
    if idx ||= @index[scid]?
      chap = @chaps[idx]
    else
      chap = append(ChapInfo.new(scid))
    end

    yield chap
    @changes += chap.reset_changes!

    chap
  end

  # save file and reset change counter
  def save!(file : String = ChapList.path_for(@ubid, @seed)) : Void
    color = changed? ? :yellow : :cyan
    puts "- <chap_list> [#{file.colorize(color)}] saved \
            (changes: #{@changes.colorize(color)})."

    ChapList.mkdir!(@ubid) # prevent missing folder
    File.write(file, to_json)
    @changes = 0
  end

  # class methods

  DIR = File.join("var", "appcv", "chlists")
  FileUtils.mkdir_p(DIR)

  # creat new folder inside `DIR` for this book
  def self.mkdir!(ubid : String)
    FileUtils.mkdir_p(File.join(DIR, ubid))
  end

  # all chap list file in `ubid` folder, return all files if no `ubid` provided
  def self.files(ubid : String = "**") : Array(String)
    Dir.glob(File.join(DIR, ubid, "*.json"))
  end

  # generate file path of chap list base from `DIR`
  def self.path_for(ubid : String) : String
    File.join(DIR, ubid)
  end

  # generate file path of chap list base from `DIR`
  def self.path_for(ubid : String, seed : String) : String
    File.join(DIR, ubid, "#{seed}.json")
  end

  # extract ubid name from filename
  def self.ubid_for(file : String) : String
    File.basename(File.dirname(file))
  end

  # extract seed name from filename
  def self.seed_for(file : String) : String
    file.sub(DIR)
    File.basename(file, ".json")
  end

  # check if chap list exists
  def self.exists?(ubid : String, seed : String)
    File.exists?(path_for(ubid, seed))
  end

  # return true if chap list not found or has mtime smaller than `time`
  def self.outdated?(ubid : String, seed : String, time : Time)
    file = path_for(ubid, seed)
    return true unless File.exists?(file)
    File.info(file).modification_time < time
  end

  # read chap list file if exists, raise error if not found
  def self.read!(file : String) : ChapList
    read(file) || raise "<chap_list> file [#{file}] not found!"
  end

  # read file if exists, return nil if error, delete file if parsing error.
  def self.read(file : String) : ChapList?
    return unless File.exists?(file)
    # puts "- <chap_list> [#{file.colorize.blue}] loaded."
    from_json(File.read(file))
  rescue err
    puts "- <chap_list> error parsing file [#{file}], err: #{err}".colorize.red
    File.delete(file)
  end

  # load chap list by book `ubid` and `seed` name
  def self.get(ubid : String, seed : String) : ChapList?
    read(path_for(ubid, seed))
  end

  # load chap list, raise error if not found
  def self.get!(ubid : String, seed : String) : ChapList
    get(ubid, seed) || raise "<chap_list> list [#{ubid}/#{seed}] not found!"
  end

  # load chap list or create new one
  def self.get_or_create(ubid : String, seed : String) : ChapList
    get(ubid, seed) || new(ubid, seed)
  end

  # load all chap lists for one book
  def self.load_all!(ubid : String)
    lists = [] of ChapList
    files(ubid).each { |file| lists << read!(file) }

    puts "- <chap_list> loaded all chap lists for [#{ubid}] \
            (count: #{lists.size.colorize.yellow})."

    lists
  end

  # cache chap lists for faster access
  CACHE = {} of String => ChapList
  # only cache newest ones due to low memory constraint
  CACHE_LIMIT = 1000

  # load with caching, raise error if chap list does not exists.
  def self.preload!(ubid : String, seed : String) : ChapList
    CACHE.shift if CACHE.size > LIMIT
    CACHE[cache_key(ubid, seed)] ||= get!(ubid, seed)
  end

  # load with caching, create new entry if not exists
  def self.preload_or_create!(ubid : String, seed : String) : ChapList
    CACHE.shift if CACHE.size > LIMIT
    CACHE[cache_key(ubid, seed)] ||= get_or_create(ubid, seed)
  end

  # generate unique cache key
  private def self.cache_key(ubid : String, seed : String) : String
    "#{ubid}/#{seed}"
  end

  # preload all chap lists for one book to cache
  def self.preload_all!(ubid : String)
    lists = [] of ChapList
    files(ubid).each { |file| lists << preload!(ubid, seed_for(file)) }

    puts "- <chap_list> loaded all chap lists for [#{ubid}] to cache \
            (count: #{lists.size.colorize.yellow})."

    lists
  end
end
