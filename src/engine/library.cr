require "file_utils"

require "./library/*"

module CV::Library
  extend self

  DIR = "_db/cvdict/active"
  ::FileUtils.mkdir_p(DIR)

  class_getter trungviet : VpDict { load_dict("trungviet", dtype: 1, dlock: 4) }
  class_getter cc_cedict : VpDict { load_dict("cc_cedict", dtype: 1, dlock: 4) }

  alias Lookups = NamedTuple(trungviet: VpDict, cc_cedict: VpDict)
  class_getter lookups : Lookups { {trungviet: trungviet, cc_cedict: cc_cedict} }

  class_getter tradsim : VpDict { find_dict("tradsim") }
  class_getter binh_am : VpDict { find_dict("binh_am") }
  class_getter hanviet : VpDict { find_dict("hanviet") }

  class_getter regular : VpDict { find_dict("regular") }
  class_getter various : VpDict { find_dict("various") }
  class_getter suggest : VpDict { find_dict("suggest") }

  DICTS = {} of String => VpDict

  def find_dict(dname : String)
    DICTS[dname] ||=
      case dname
      when "tradsim", "binh_am", "hanviet"
        load_dict(dname, dtype: 1, dlock: 3, preload: true)
      when "regular", "suggest", "various"
        load_dict(dname, dtype: 2, dlock: 2, preload: true)
      else
        load_dict(dname, dtype: 3, dlock: 1, preload: true)
      end
  end

  def load_dict(dname : String, dtype = 1, dlock = 0, preload = true)
    VpDict.new(file_path(dname), dtype: dtype, dlock: dlock, preload: preload)
  end

  def file_path(dname : String, ext : String = "tsv")
    case dname
    when "trungviet", "cc_cedict", "trich_dan"
      "#{DIR}/#{dname}.#{ext}"
    when "tradsim", "binh_am", "hanviet"
      "#{DIR}/common/#{dname}.#{ext}"
    when "regular", "suggest", "various"
      "#{DIR}/common/#{dname}.#{ext}"
    else
      "#{DIR}/unique/#{dname}.#{ext}"
    end
  end

  class_getter dict_logs : VpLogs { VpLogs.new(DIR) }

  def upsert(dname : String, key : String, vals : Array(String), attr = "", uname = 0, plock = 1, mtime = 0, context = "") : Bool
    mtime = VpTerm.mtime if mtime <= 0
    new_term = VpTerm.new(key, vals, attr, mtime, uname, plock)

    dict = load_dict(dname)
    prevail, old_term = dict.upsert!(new_term)

    log_entry = VpLogs::Entry.new(dname, new_term, old_term, prevail, context)
    dict_logs.insert!(file_path(dname, "tab"), log_entry)

    prevail
  end

  def lookup(dname : String, key : String)
    # TODO!
    output = {} of String => Array(String)

    load_dict(dname).scan(key.chars) do |term|
      output[term.key] = term.vals
    end

    output
  end
end

# puts CV::Library.lookup("trungviet", "覆盖面")
