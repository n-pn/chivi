require "./library/base_dict"
require "./library/user_dict"

module Libcv::Library
  extend self

  # DIR = File.join("var", "libcv")
  # FileUtils.mkdir_p(File.join(DIR, "lexicon", "core"))
  # FileUtils.mkdir_p(File.join(DIR, "lexicon", "uniq"))

  class_getter cc_cedict : BaseDict { BaseDict.load!("cc_cedict") }
  class_getter trungviet : BaseDict { BaseDict.load!("trungviet") }

  class_getter tradsim : BaseDict { BaseDict.load!("_tradsim") }
  class_getter binh_am : BaseDict { BaseDict.load!("_binh_am") }

  class_getter hanviet : UserDict { UserDict.load("core/hanviet", power: 3) }
  class_getter generic : UserDict { UserDict.load("core/generic", power: 2) }
  class_getter suggest : UserDict { UserDict.load("core/suggest", power: 1) }

  def for_convert(name : String) : Tuple(BaseDict, BaseDict)
    name = "_tonghop" if name.empty?
    {generic.dict, UserDict.load("uniq/#{name}").dict}
  end

  def load_dict(name : String) : UserDict
    case name
    when "generic" then generic
    when "hanviet" then hanviet
    when "suggest" then suggest
    else                UserDict.load("uniq/#{name}")
    end
  end

  def upsert(dname : String, uname : String, power : Int32, key : String, val : String = "")
    dname = "_tonghop" if dname.empty?
    entry = DictEdit.new(key, val, uname: uname, power: power)
    load_dict(dname).insert(entry, freeze: true)
  end

  # def search(term : String, dname = "generic")
  #   dict = load_dict(dname)
  #   item, edit, hints = dict.find(term)

  #   {
  #     vals:  item.try(&.vals) || [] of String,
  #     mtime: edit.try(&.utime) || 0,
  #     uname: edit.try(&.uname) || "",
  #     power: edit.try(&.power) || dict.power,
  #     hints: hints.try(&.uniq.last(3)) || [] of String,
  #   }
  # end
end
