require "file_utils"

require "./library/*"

module Chivi::Library
  extend self

  DIR = "_db/cvdict/active"
  FileUtils.mkdir_p(DIR)

  alias Lookups = NamedTuple(
    trungviet: VpDict,
    cc_cedict: VpDict,
    trich_dan: VpDict)
  class_getter lookups : Lookups {
    {
      trungviet: VpDict.new(file_path("trungviet")),
      cc_cedict: VpDict.new(file_path("cc_cedict")),
      trich_dan: VpDict.new(file_path("trich_dan")),
    }
  }

  class_getter tradsim : VpDict { load_dict("tradsim", 3) }
  class_getter binh_am : VpDict { load_dict("binh_am", 3) }
  class_getter hanviet : VpDict { load_dict("hanviet", 3) }

  class_getter regular : VpDict { load_dict("regular", 2) }
  class_getter various : VpDict { load_dict("various", 1) }
  class_getter suggest : VpDict { load_dict("suggest", 0) }

  DICTS = {} of String => LEXICON

  def load_dict(dname : String, plock = 1)
    DICTS[dname] ||= VpDict.new(file_path(dname), plock)
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
  end
end
