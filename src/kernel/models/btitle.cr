require "./_models"
require "../mapper/value_map"

class Chivi::Btitle
  include Clear::Model
  self.table = "btitles"

  primary_key type: :serial
  timestamps

  column zh_name : String
  column hv_name : String
  column vi_name : String?

  column zh_name_tsv : Array(String), presence: false
  column hv_name_tsv : Array(String), presence: false
  column vi_name_tsv : Array(String), presence: false

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

    unless vi_name || model.vi_name_column.defined?
      vi_name = fix_vi_name(zh_name)
    end

    if vi_name && vi_name != model.vi_name_column.value(nil)
      model.vi_name = vi_name
      model.vi_name_tsv = SeedUtils.tokenize(vi_name)
    end

    model.save! if model.hv_name_column.changed? || model.vi_name_column.changed?
    model
  end

  ZH_BTITLES = ValueMap.new("src/kernel/_fixes/zh_btitles.tsv")
  VI_BTITLES = ValueMap.new("src/kernel/_fixes/vi_btitles.tsv")

  def self.fix_zh_name(zh_title : String, author : String = "")
    # cleanup trashes
    title = SeedUtils.fix_spaces(zh_title).sub(/[（\(].+[\)）]\s*$/, "").strip

    ZH_BTITLES.get_value("#{title}  #{author}") || ZH_BTITLES.get_value(title) || title
  end

  def self.fix_vi_name(zh_title : String)
    VI_BTITLES.get_value(zh_title).try { |x| SeedUtils.titleize(x) }
  end
end

# puts Chivi::Btitle.upsert!("小郎君").to_json
