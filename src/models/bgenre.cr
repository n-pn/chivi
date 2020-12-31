require "./_models"

class CV::Models::Bgenre
  include Clear::Model
  self.table = "bgenres"

  primary_key type: :serial

  column zh_name : String
  column vi_name : String
  column vi_slug : String

  timestamps

  def self.find_by_slug(name : String)
    find({vi_slug: SeedUtils.slugify(name)})
  end

  def self.upsert_all!(zh_name : String)
    fix_zh_name(zh_name).map { |name| upsert!(name) }
  end

  def self.upsert!(zh_name : String, vi_name : String? = nil)
    model = find({zh_name: zh_name}) || new({zh_name: zh_name})

    unless vi_name || model.vi_name_column.defined?
      vi_name = fix_vi_name(zh_name)
    end

    if vi_name && vi_name != model.vi_name_column.value(nil)
      model.vi_name = vi_name
      model.vi_slug = SeedUtils.slugify(vi_name)
    end

    model.save! if model.vi_name_column.changed?
    model
  end

  ZH_FIXES_FILE = "src/kernel/_fixes/zh_bgenres.tsv"
  VI_FIXES_FILE = "src/kernel/_fixes/vi_bgenres.tsv"

  class_getter zh_bgenres : ValueMap { ValueMap.new(ZH_FIXES_FILE) }
  class_getter vi_bgenres : ValueMap { ValueMap.new(VI_FIXES_FILE) }

  def self.fix_zh_name(zh_genre : String) : Array(String)
    zh_genre = zh_genre.sub(/小说$/, "") unless zh_genre == "轻小说"

    if value = zh_bgenres.get_value(zh_genre)
      value.split("  ")
    else
      puts "[UNKNOWN GENRE: #{zh_genre}]"
      [] of String
    end
  end

  def self.fix_vi_name(zh_genre : String) : String
    vi_bgenres.get_value(zh_genre) || ModelUtils.to_hanviet(zh_genre, as_title: true)
  end
end
