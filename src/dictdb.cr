require "./dictdb/*"

module DictDB
  extend self

  DIR = File.join("var", "dictdb")

  FileUtils.mkdir_p(File.join(DIR, "core"))
  FileUtils.mkdir_p(File.join(DIR, "uniq"))

  class_getter cc_cedict : BaseDict { BaseDict.load!("cc_cedict") }
  class_getter trungviet : BaseDict { BaseDict.load!("trungviet") }

  class_getter tradsim : BaseDict { BaseDict.load!("_tradsim") }
  class_getter binh_am : BaseDict { BaseDict.load!("_binh_am") }
  class_getter hanviet : BaseDict { BaseDict.load!("_hanviet") }

  class_getter generic : UserDict { UserDict.load("core/generic") }
  class_getter suggest : UserDict { UserDict.load("core/suggest") }
  class_getter combine : UserDict { UserDict.load("uniq/_tonghop") }

  def for_convert(name : String) : Tuple(BaseDict, BaseDict, BaseDict)
    name = "_tonghop" if name.empty?
    {hanviet, generic.dict, UserDict.load("uniq/#{name}").dict}
  end

  def find_dict(name : String)
    case name
    when "generic" then generic
    when "hanviet" then hanviet
    when "combine" then combine
    else                UserDict.load("uniq/#{name}")
    end
  end

  def upsert(dname : String, uname : String, power : Int32, key : String, val : String = "")
    dname = "_combine" if dname.empty?
    entry = DictEdit.new(key, val, uname: uname, power: power)

    dict = find_dict(dname)
    raise "power too low" unless dict.insert!(entry)
  end

  def search(term : String, dname = "generic")
    mtime = 0
    uname = ""
    power = 0

    vals = [] of String

    if node = BaseDict.load_unsure(dname).find(term)
      power = 1

      vals = node.vals
    end

    if edit = UserDict.load_unsure(dname).find(term)
      mtime = edit.mtime
      uname = edit.uname
      power = edit.power

      vals = DictTrie.split(edit.val) if vals.empty?
    end

    mtime = (DictEdit::EPOCH + mtime.minutes).to_unix_ms
    {vals: vals, mtime: mtime, uname: uname, power: power}
  end
end
