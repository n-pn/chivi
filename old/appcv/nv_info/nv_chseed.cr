require "./nv_utils"

module CV::NvChseed
  extend self

  DIR = "_db/nv_infos/chseeds"
  ::FileUtils.mkdir_p(DIR)

  class_getter _index : TokenMap { TokenMap.new "#{DIR}/_index.tsv" }
  CACHE = {} of String => TsvStore

  def get_list(bhash : String)
    _index.get(bhash) || ["chivi"]
  end

  def set_list!(bhash : String, chseed : Array(String))
    _index.set!(bhash, chseed)
  end

  def get_seed(sname : String, bhash : String)
    seed_map(sname).get(bhash)
  end

  def get_nvid(sname : String, bhash : String)
    seed_map(sname).fval(bhash)
  end

  def set_seed!(sname : String, bhash : String, values : Array(String))
    seed_map(sname).set!(bhash, values)
  end

  def seed_map(sname : String)
    CACHE[sname] ||= TsvStore.new("#{DIR}/#{sname}.tsv")
  end

  def filter(inp : String, prevs : Set(String)? = nil)
    res = _index.keys(inp.downcase)
    prevs ? prevs & res : res
  end

  def save!(clean : Bool = false)
    @@_index.try(&.save!(clean: clean))
    CACHE.each_value(&.save!(clean: clean))
  end
end
