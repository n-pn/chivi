require "./lexicon/*"

module Lexicon
  DIR = "data/lx_files"

  @@HOME = LxRepo.new(DIR)
  @@CORE = LxRepo.new(File.join(DIR, "core"))
  @@BOOK = LxRepo.new(File.join(DIR, "book"))

  @@cc_cedict : LxDict? = nil
  @@trungviet : LxDict? = nil

  def self.cc_cedict
    @@cc_cedict ||= @@HOME["cc_cedict"]
  end

  def self.trungviet
    @@trungviet ||= @@HOME["trungviet"]
  end

  def self.shared(dict : String = "combine", user = "local")
    LxPair.new(@@CORE[dict, user], @@CORE[dict])
  end

  def self.unique(dict : String = "tonghop", user = "local")
    LxPair.new(@@BOOK[dict, user], @@BOOK[dict])
  end

  def self.for_convert(name : String = "tonghop", user : String = "local")
    [shared("generic", user), unique(name, user)]
  end
end
