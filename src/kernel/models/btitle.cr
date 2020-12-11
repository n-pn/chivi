require "./_models"

class Chivi::Btitle
  include Clear::Model
  self.table = "btitles"

  column id : Int32, primary: true, presence: false

  column zh_name : String
  column hv_name : String
  column vi_name : String

  column zh_name_tsv : Array(String)
  column hv_name_tsv : Array(String)
  column vi_name_tsv : Array(String)

  def self.glob_all(name : String)
    glob_all(SeedUtils.tokenize(name))
  end

  def self.glob_all(tokens : Array(String))
    query.where("zh_name_tsv @> :a OR hv_name_tsv @> :a OR vi_name_tsv @> :a", a: tokens)
  end

  def self.upsert!(zh_name : String, hv_name : String? = nil, vi_name : String? = nil) : self
    unless model = find({zh_name: zh_name})
      model = new({zh_name: zh_name, zh_name_tsv: SeedUtils.tokenize(zh_name)})
    end

    unless hv_name || model.hv_name_column.defined?
      hv_name = ModelUtils.to_hanviet(zh_name, as_title: true)
    end

    if hv_name && hv_name != model.hv_name_column.value(nil)
      model.hv_name = hv_name
      model.hv_name_tsv = SeedUtils.tokenize(hv_name)
    end

    if vi_name && vi_name != model.vi_name_column.value(nil)
      model.vi_name = vi_name
      model.vi_name_tsv = SeedUtils.tokenize(vi_name)
    end

    model.save! if model.hv_name_column.changed? || model.vi_name_column.changed?
    model
  end
end

puts Chivi::Btitle.upsert!("小郎君").to_json
