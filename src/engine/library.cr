require "file_utils"

require "./library/*"

module Chivi::Library
  extend self

  DIR = "_db/cvdict/active"
  FileUtils.mkdir_p(DIR)

  alias Lookups = NamedTuple(
    trungviet: Lexicon,
    cc_cedict: Lexicon,
    trich_dan: Lexicon)
  class_getter lookups : Lookups {
    {
      trungviet: Lexicon.new(file_path("trungviet")),
      cc_cedict: Lexicon.new(file_path("cc_cedict")),
      trich_dan: Lexicon.new(file_path("trich_dan")),
    }
  }

  class_getter tradsim : Lexicon { load_dict("tradsim", 3) }
  class_getter binh_am : Lexicon { load_dict("binh_am", 3) }
  class_getter hanviet : Lexicon { load_dict("hanviet", 3) }

  class_getter regular : Lexicon { load_dict("regular", 2) }
  class_getter various : Lexicon { load_dict("various", 1) }
  class_getter suggest : Lexicon { load_dict("suggest", 0) }

  DICTS = {} of String => LEXICON

  def load_dict(dname : String, plock = 1)
    DICTS[dname] ||= Lexicon.new(file_path(dname), plock)
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

  class_getter history : History { History.new(DIR) }

  def upsert(dname : String, key : String, vals : Array(String), attr = "", uname = 0, plock = 1, mtime = 0, ctx = "")
    dict = load_dict(dname)

    mtime = Lexicon::Item.mtime if mtime <= 0
    new_item = Lexicon::Item.new(key, vals, attr, mtime, uname, plock)
    old_item = dict.upsert!(new_item)

    history.record!(file_path(dname, "tab"), new_item, old_item, ctx: ctx)
  end

  def lookup(dname : String, key : String)
  end
end
