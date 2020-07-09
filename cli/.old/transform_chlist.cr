require "../../src/kernel/chap_list"

class OldChapList
  include BaseModel

  getter uuid : String
  getter seed : String

  property sbid = ""
  property type = 0

  getter data = {} of String => ChapItem
  @sort = [] of String # manual sort

  forward_missing_to @data

  def initialize(@uuid : String, @seed : String)
    @changes = 1
  end

  def upsert(chap : ChapItem, mode = 0)
    return if mode == 0 && @data.has_key?(chap.scid)

    upsert(chap.scid) do |old_chap|
      old_chap.set_title(chap.title, chap.label)
    end
  end

  def upsert(scid : String)
    chap = @data[scid] ||= ChapItem.new(scid)
    yield chap

    @changes += chap.reset_changes!
    chap
  end

  def sort
    @sort.empty? ? @data.keys : @sort
  end

  def save!(file : String = ChapList.path_for(@uuid, @seed)) : Void
    ChapList.mkdir!(@uuid)
    File.write(file, to_json)

    puts "- <chap_list> [#{file.colorize(:yellow)}] saved \
            (#{@changes.colorize(:yellow)} changes)."
  end

  # class methods

  DIR = File.join("var", "old.chap_lists")
  FileUtils.mkdir_p(DIR)

  def self.mkdir!(uuid : String)
    FileUtils.mkdir_p(File.join(DIR, uuid))
  end

  def self.glob_dir(uuid : String) : Array(String)
    Dir.glob(File.join(DIR, uuid, "*.json"))
  end

  def self.path_for(uuid : String, seed : String)
    File.join(DIR, uuid, "#{seed}.json")
  end

  def exists?(uuid : String, seed : String)
    File.exists?(path_for(uuid, seed))
  end

  CACHE = Hash(String, Hash(String, ChapList)).new do |h, k|
    h[k] = {} of String => ChapList
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

  def self.load_file(file : String)
    puts "- <chap_list> [#{file.colorize(:blue)}] loaded."
    from_json(File.read(file))
  end
end

uuids = Dir.children(OldChapList::DIR)

puts uuids.size
uuids.each do |uuid|
  files = Dir.glob(File.join(OldChapList::DIR, uuid, "*.json"))

  files.each do |file|
    old_data = OldChapList.load_file(file)
    new_data = ChapList.new(uuid, File.basename(file, ".json"))

    old_data.data.each_value do |item|
      new_data.upsert(item)
    end

    new_data.save!
  end
end
