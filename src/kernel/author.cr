require "./_models"
require "./mapper/value_map"

class Chivi::Author
  include Clear::Model
  self.table = "authors"

  primary_key type: :serial

  column zh_name : String
  column vi_name : String

  column zh_name_tsv : Array(String) = [] of String
  column vi_name_tsv : Array(String) = [] of String

  timestamps

  def set_zh_name(input : String, force : Bool = false)
    return unless force || input != self.zh_name_column.value(nil)

    self.zh_name = input
    self.zh_name_tsv = SeedUtils.tokenize(input)
  end

  def set_vi_name(input : String, force : Bool = false)
    return unless force || input != self.vi_name_column.value(nil)

    self.vi_name = input
    self.vi_name_tsv = SeedUtils.tokenize(input)
  end

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
      model = new.tap(&.set_zh_name(zh_name))
    end

    unless vi_name || mode.vi_name_column.defined?
      vi_name = fix_vi_name(zh_name)
    end

    mode.set_vi_name(vi_name) if vi_name

    model.save! if model.vi_name_column.changed?
    model
  end

  ZH_FIXES_FILE = "src/kernel/_fixes/zh_authors.tsv"
  VI_FIXES_FILE = "src/kernel/_fixes/vi_authors.tsv"

  class_getter zh_authors : ValueMap { ValueMap.new(ZH_FIXES_FILE) }
  class_getter vi_authors : ValueMap { ValueMap.new(VI_FIXES_FILE) }

  def self.fix_zh_name(author : String, title : String = "") : String
    # cleanup trashes
    author =
      SeedUtils.fix_spaces(author)
        .sub(/\.QD\s*$/, "")
        .sub(/[（\(].+[\)）]$/, "")

    unless zh_authors.get_value("#{title}  #{author}")
      zh_authors.get_value(author) || author
    end
  end

  def self.fix_vi_name(zh_name : String) : String
    unless vi_authors.get_value(zh_name)
      ModelUtils.to_hanviet(zh_name, as_title: true)
    end
  end
end

# puts Chivi::Author.upsert!("小郎君").to_json
# puts Chivi::Author.upsert!("小郎君").to_json

# puts Chivi::Author.find_any("卖报小郎君").to_json
# puts Chivi::Author.glob_all("小郎君").to_a.to_json
# puts Chivi::Author.glob_all("tieu lang").to_a.to_json
