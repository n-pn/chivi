require "./_models"

class Chivi::Bgenre
  include Clear::Model
  self.table = "bgenres"

  column id : Int32, primary: true, presence: false

  column name_zh : String
  column name_vi : String = ""
  column slug_vi : String = ""

  def set_name(name_zh : String, name_vi : String = "")
    self.name_zh = name_zh
    name_vi = ModelUtils.to_hanviet(name_zh, as_title: true) if name_vi.empty?
    self.name_vi = name_vi
    self.slug_vi = SeedUtil.slugify(name_vi)
  end

  def self.find(name : String)
    query.where(slug_vi: SeedUtil.slugify(name)).first
  end
end
