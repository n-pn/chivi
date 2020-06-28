require "./dictdb/*"

module DictDB
  ROOT = File.join("var", "libcv")

  @@LOOKUP = LxRepo.new(File.join(ROOT, "lookup"))
  @@SHARED = LxRepo.new(File.join(ROOT, "shared"))
  @@UNIQUE = LxRepo.new(File.join(ROOT, "unique"))

  @@cc_cedict : LxDict? = nil
  @@trungviet : LxDict? = nil

  def self.cc_cedict
    @@cc_cedict ||= @@LOOKUP["cc_cedict"]
  end

  def self.trungviet
    @@trungviet ||= @@LOOKUP["trungviet"]
  end

  def self.shared(dict : String = "combine", user = "local")
    LxPair.new(@@SHARED[dict, user], @@SHARED[dict])
  end

  def self.unique(dict : String = "tonghop", user = "local")
    LxPair.new(@@UNIQUE[dict, user], @@UNIQUE[dict])
  end

  def self.for_convert(name : String = "tonghop", user : String = "local")
    [shared("generic", user), unique(name, user)]
  end
end
