require "file_utils"
require "../../src/seeds/rm_info"
require "../../src/tsvfs/value_map"
require "./bootstrap"

module CV::SeedUtil
  extend self

  class_getter rating_fix : ValueMap { load_map("rating_fix", 2) }
  class_getter status_map : ValueMap { load_map("status_map", 2) }

  class_getter authors_map : Hash(String, Author) do
    Author.query.to_a.to_h { |x| {x.zname, x} }
  end

  def save_maps!(clean = false)
    @@status_map.try(&.save!(clean: clean))
  end

  def load_map(label : String, mode = 1)
    ValueMap.new("_db/zhbook/#{label}.tsv", mode: mode)
  end

  def get_author(author : String, ztitle = "", force = false) : Author?
    zname = BookUtils.fix_zh_author(author, ztitle)
    authors_map[zname] ||= begin
      return unless force
      Author.upsert!(zname)
    end
  end

  def parse_status(status_str : String)
    return 0 if status_str.empty?

    unless status_int = status_map.fval(status_str)
      print " - status int for <#{status_str}>: "

      if status_int = gets.try(&.strip)
        status_map.set!(status_str, status_int)
      end
    end

    status_int.try(&.to_i?) || 0
  end

  def get_mtime(file : String) : Int64
    File.info?(file).try(&.modification_time.to_unix) || 0_i64
  end
end

# puts CV::SeedUtil.last_snvid("69shu")
