require "./_models"
require "../../engine/convert"
require "../../shared/seed_utils"

class Chivi::Author
  include Clear::Model
  self.table = "authors"

  column id : Int32, primary: true, presence: false

  column zh_name : String
  column zh_name_tsv : Array(String) = [] of String

  column vi_name : String = ""
  column vi_name_tsv : Array(String) = [] of String

  def set_name(zh_name : String, vi_name : String = "")
    set_zh_name(zh_name)

    if vi_name.empty?
      vi_name = Chivi::Convert.convert(zh_name, "hanviet")
      vi_name = SeedUtils.titleize(vi_name)
    end

    set_vi_name(vi_name)
  end

  def set_zh_name(zh_name : String)
    self.zh_name = zh_name
    self.zh_name_tsv = Chivi::SeedUtils.tokenize(zh_name, keep_accent: true)
  end

  def set_vi_name(vi_name : String)
    self.vi_name = vi_name
    self.vi_name_tsv = Chivi::SeedUtils.tokenize(vi_name)
  end

  def self.find(name : String)
    query.where { (zh_name == name) | (vi_name == name) }.first
  end

  def self.glob(name : String)
    tsv = Chivi::SeedUtils.tokenize(name)
    query.where("zh_name_tsv @> :tsv OR vi_name_tsv @> :tsv", tsv: tsv)
  end
end

# author = Chivi::Author.new
# author.set_name("卖报小郎君")
# author.save!
# puts Chivi::Author.find("卖报小郎君").to_pretty_json
# puts Chivi::Author.glob("卖报").to_a.to_json
