require "file_utils"
require "../../mapper/*"

module CV::NvChseed
  extend self

  class_getter _index : TokenMap { TokenMap.new(file_path("_index"), mode: 1) }

  alias Chseed = Tuple(String, Int32, Int32)

  def get_chseed(bhash : String) : Hash(String, Chseed)
    output = {} of String => Chseed
    return output unless snames = _index.get(bhash)

    snames.each_with_object(output) do |sname, hash|
      next unless value = load(sname).get(bhash)
      next unless value.size == 3
      hash[sname] = {value[0], value[1].to_i, value[2].to_i}
    end
  end

  def put_chseed(bhash : String, sname : String, snvid : String, mtime = 0, total = 0)
    load(sname)
      .tap(&.add(bhash, [snvid, mtime.to_s, total.to_s]))
      .save!(mode: :upds)
  end

  def set_snames(bhash : String, snames : Array(String)) : Nil
    _index.add(bhash, snames)
    _index.save!(mode: :upds)
  end

  DIR = "_db/nvdata/chseeds"
  ::FileUtils.mkdir_p(DIR)

  def file_path(label : String)
    "#{DIR}/#{label}.tsv"
  end

  CACHE = {} of String => ValueMap

  def load(sname : String) : ValueMap
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
