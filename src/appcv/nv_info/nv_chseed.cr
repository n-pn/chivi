require "./nv_utils"

module CV::NvChseed
  extend self

  DIR = "_db/nv_infos/chseeds"

  class_getter _index : TokenMap { TokenMap.new "#{DIR}/_index.tsv" }

  CACHE = {} of String => ValueMap

  def get_list(bhash : String)
    _index.get(bhash) || ["chivi"]
  end

  def set_list!(bhash : String, chseed : Array(String))
    _index.set!(bhash, chseed)
  end

  def get_seed(sname : String, bhash : String)
    seed_map(sname).get(bhash)
  end

  def set_seed!(sname : String, bhash : String, values : Array(String))
    seed_map(sname).set!(bhash, values)
  end

  def seed_map(sname : String)
    CACHE[sname] ||= ValueMap.new("#{DIR}/#{sname}.tsv")
  end

  def save!(clean : Bool = false)
    @@_index.try(&.save!(clean: clean))
    CACHE.each_value(&.save!(clean: clean))
  end

  def filter(inp : String, prevs : Set(String)? = nil)
    res = _index.keys(inp.downcase)
    prevs ? prevs & res : res
  end
end
