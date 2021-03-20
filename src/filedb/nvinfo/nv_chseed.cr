require "file_utils"
require "../../mapper/*"

module CV::NvChseed
  extend self

  alias Seed = Tuple(String, Int32, Int32) # snvid, updated_at, chap_count
  class_getter _index : TokenMap { TokenMap.new(map_path("_index"), mode: 1) }

  DIR = "_db/nvdata/chseeds"
  ::FileUtils.mkdir_p(DIR)

  def map_path(label : String)
    File.join(DIR, "#{label}.tsv")
  end

  def get_chseed(bhash : String) : Array(Seed)
    snames = _index.get(bhash) || [] of String
    output = snames.map do |sname|
      next unless seed = load_map(sname).get(bhash)
      next unless seed.size == 3
      {seed[0], seed[1].to_i, seed[2].to_i}
    end

    output.sort_by(&[1].-) # sort by updated_at
  end

  def put_chseed(bhash : String, sname : String, snvid : String, mtime = 0, total = 0)
    m apper = load_map(sname)
    mapper.set!(bhash, [snvid, mtime.to_s, total.to_s])
    mapper.save!(clean: false)
  end

  def set_snames(bhash : String, snames : Array(String)) : Nil
    _index.set!(bhash, snames)
    _index.save!(clean: false)
  end

  CACHE = {} of String => ValueMap

  def load_map(sname : String) : ValueMap
    CACHE[sname] ||= ValueMap.new(file_path(sname), mode: 1)
  end

  def save!(mode : Symbol = :upds)
    @@_index.try(&.save!(mode: mode))
    CACHE.each_value(&.save!(mode: mode))
  end

  def glob(query : String, prevs : Set(String)? = nil)
    res = _index.keys(query.downcase)
    prevs ? prevs & res : res
  end
end
