require "./_models"

class Chivi::Btitle
  include Clear::Model
  self.table = "btitles"

  column id : Int32, primary: true, presence: false

  column name_zh : String
  column name_zh_tsv : Array(String) = [] of String

  column name_vi : String = ""
  column name_vi_tsv : Array(String) = [] of String

  def set_name(name_zh : String, name_vi : String = "")
    set_name_zh(name_zh)

    name_vi = ModelUtils.to_hanviet(name_zh, as_title: true) if name_vi.empty?
    set_name_vi(name_vi)
  end

  def set_name_zh(name_zh : String)
    self.name_zh = name_zh
    self.name_zh_tsv = SeedUtils.tokenize(name_zh)
  end

  def set_name_vi(name_vi : String)
    self.name_vi = name_vi
    self.name_vi_tsv = SeedUtils.tokenize(name_vi)
  end

  def self.find(name : String)
    query.where { (name_zh == name) | (name_vi == name) }.first
  end

  def self.glob(name : String)
    tsv = SeedUtils.tokenize(name)
    query.where("name_zh_tsv @> :tsv OR name_vi_tsv @> :tsv", tsv: tsv)
  end
end

# btitle = Chivi::Btitle.new
# btitle.set_name("卖报小郎君")
# btitle.save!
# puts Chivi::Btitle.find("卖报小郎君").to_pretty_json
# puts Chivi::Btitle.glob("卖报").to_a.to_json
