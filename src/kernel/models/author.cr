require "./_models"
require "../../engine/convert"
require "../../shared/seed_utils"

class Chivi::Author
  include Clear::Model
  self.table = "authors"

  primary_key type: :serial
  timestamps

  column zh_name : String
  column vi_name : String

  column zh_name_tsv : Array(String) = [] of String
  column vi_name_tsv : Array(String) = [] of String

  def self.find_any(name : String)
    query.where { (zh_name == name) | (vi_name == name) }.first
  end

  def self.glob_all(name : String)
    glob_all(SeedUtils.tokenize(name))
  end

  def self.glob_all(tokens : Array(String))
    query.where("zh_name_tsv @> :a OR vi_name_tsv @> :a", a: tokens)
  end

  def self.upsert!(zh_name : String, vi_name : String? = nil) : self
    unless model = find({zh_name: zh_name})
      model = new({zh_name: zh_name, zh_name_tsv: SeedUtils.tokenize(zh_name)})
    end

    unless vi_name || model.vi_name_column.defined?
      vi_name = fix_vi_name(zh_name) || ModelUtils.to_hanviet(zh_name, as_title: true)
    end

    if vi_name && vi_name != model.vi_name_column.value(nil)
      model.vi_name = vi_name
      model.vi_name_tsv = SeedUtils.tokenize(vi_name)
    end

    model.save! if model.vi_name_column.changed?
    model
  end

  ZH_AUTHORS = ValueMap.new("src/kernel/_fixes/zh_authors.tsv")
  VI_AUTHORS = ValueMap.new("src/kernel/_fixes/vi_authors.tsv")

  def self.fix_zh_name(zh_author : String, title : String = "")
    # cleanup trashes
    author = SeedUtils.fix_spaces(zh_author).sub(/[（\(].+[\)）]|\.QD\s*$/, "").strip

    ZH_AUTHORS.get_value("#{title}  #{author}") || ZH_AUTHORS.get_value(author) || author
  end

  def self.fix_vi_name(zh_author : String)
    VI_AUTHORS.get_value(zh_author)
  end
end

# puts Chivi::Author.upsert!("小郎君").to_json
# puts Chivi::Author.upsert!("小郎君").to_json

# puts Chivi::Author.find_any("卖报小郎君").to_json
# puts Chivi::Author.glob_all("小郎君").to_a.to_json
# puts Chivi::Author.glob_all("tieu lang").to_a.to_json
