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

  def file_path(dname : String)
    case dname
    when "trungviet", "cc_cedict", "trich_dan"
      "#{DIR}/#{dname}.tsv"
    when "tradsim", "binh_am", "hanviet"
      "#{DIR}/common/#{dname}.tsv"
    when "regular", "suggest", "various"
      "#{DIR}/common/#{dname}.tsv"
    else
      "#{DIR}/unique/#{dname}.tsv"
    end
  end

  class_getter history : History { History.new(DIR) }

  def upsert(dname : String, key : String, vals : Array(String), attr = "", mtime = 0, plock = 0, dname = 0)

end
