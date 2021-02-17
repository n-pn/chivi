require "file_utils"
require "../../mapper/*"

module CV::NvChseed
  extend self
  DIR = "_db/nvdata/chseeds"
  ::FileUtils.mkdir_p(DIR)

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

  def put_chseed(sname : String, bhash : String, input : Chseed)
    mapper = load(sname)
    mapper.add(bhash, input.map(&.to_s))
    mapper.save!(mode: :upds)
  end

  def set_snames(bhash : String, chseed : Hash(String, Tuple)) : Nil
    snames = chseed.keys.sort_by do |sname|
      value = chseed[sname]
      {-value[2], -value[1]}
    end

    _index.add(bhash, snames)
  end

  def file_path(label : String)
    File.join(DIR, "#{label}.tsv")
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
