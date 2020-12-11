require "./_models"

class Chivi::Bgenre
  include Clear::Model
  self.table = "bgenres"

  column id : Int32, primary: true, presence: false

  column zh_name : String
  column vi_name : String
  column vi_slug : String

  def self.find_by_slug(name : String)
    find({vi_slug: SeedUtil.slugify(name)})
  end

  def upsert!(zh_name : String, vi_name : String? = nil)
    model = find({zh_name: zh_name}) || new({zh_name: zh_name})

    unless vi_name || model.vi_name_column.defined?
      vi_name = ModelUtils.to_hanviet(zh_name, as_title: true)
    end

    if vi_name && vi_name != model.vi_name_column.value(nil)
      model.vi_name = vi_name
      model.vi_slug = SeedUtil.slugify(vi_name)
    end

    model.save! if model.vi_name_column.changed?
    model
  end
end
