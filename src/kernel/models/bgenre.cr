require "./_models"
require "colorize"

class Chivi::Bgenre
  include Clear::Model
  self.table = "bgenres"

  primary_key type: :serial
  timestamps

  column zh_name : String
  column vi_name : String
  column vi_slug : String

  def self.find_by_slug(name : String)
    find({vi_slug: SeedUtils.slugify(name)})
  end

  def self.upsert_all!(zh_name : String)
    fix_zh_name!(zh_name).map { |name| upsert!(name) }
  end

  def self.upsert!(zh_name : String, vi_name : String? = nil)
    model = find({zh_name: zh_name}) || new({zh_name: zh_name})

    unless vi_name || model.vi_name_column.defined?
      vi_name = fix_vi_name!(zh_name)
    end

    if vi_name && vi_name != model.vi_name_column.value(nil)
      model.vi_name = vi_name
      model.vi_slug = SeedUtils.slugify(vi_name)
    end

    model.save! if model.vi_name_column.changed?
    model
  end

  ZH_BGENRES = ValueMap.new("src/kernel/_fixes/zh_bgenres.tsv")
  VI_BGENRES = ValueMap.new("src/kernel/_fixes/vi_bgenres.tsv")

  def self.fix_zh_name!(zh_genre : String)
    zh_genre = zh_genre.sub(/小说$/, "") unless zh_genre == "轻小说"

    if value = ZH_BGENRES.get_value(zh_genre)
      value.split("  ")
    else
      puts "[UNKNOWN GENRE: #{zh_genre}]".colorize.red
      [] of String
    end
  end

  def self.fix_vi_name!(zh_genre : String)
    VI_BGENRES.get_value(zh_genre) || ModelUtils.to_hanviet(zh_genre, as_title: true)
  end
end
