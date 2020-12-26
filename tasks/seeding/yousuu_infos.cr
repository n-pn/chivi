require "file_utils"

require "../../src/_seeds/ys_info"
require "../../src/kernel/mapper/value_map"
require "./_info_seeding.cr"

class Chivi::SeedInfoYousuu
  getter seeding = InfoSeeding.new("yousuu")

  getter extra_tags : ValueMap { ValueMap.new(seeding.map_path("extra_tags")) }

  getter source_url : ValueMap { ValueMap.new(seeding.map_path("source_url")) }
  getter crit_count : ValueMap { ValueMap.new(seeding.map_path("crit_count")) }
  getter list_count : ValueMap { ValueMap.new(seeding.map_path("list_count")) }
  getter word_count : ValueMap { ValueMap.new(seeding.map_path("word_count")) }

  def init!
    input = Dir.glob("_db/.cache/yousuu/infos/*.json").sort_by do |file|
      File.basename(file, ".json").to_i
    end

    puts "- Input: #{input.size} files.".colorize.cyan

    input.each_with_index do |file, idx|
      ybid = File.basename(file, ".json")

      access = File.info(file).modification_time.to_unix
      next if @seeding.access.get_value(ybid).try(&.to_i64.> access)
      @seeding.access.upsert(ybid, access.to_s)

      next unless info = YsInfo.load(file)
      puts "- <#{idx + 1}/#{input.size}> [#{info.title}  #{info.author}]".colorize.blue

      @seeding._index.upsert(ybid, "#{info.title}  #{info.author}")
      @seeding.set_intro(ybid, info.intro)
      @seeding.genres.upsert(ybid, info.genre)
      @seeding.covers.upsert(ybid, info.cover_fixed)

      @seeding.rating.upsert(ybid, "#{info.voters}  #{info.rating}")
      @seeding.update.upsert(ybid, info.updated_at.to_unix.to_s)

      extra_tags.upsert(ybid, info.tags_fixed.join("  "))
      source_url.upsert(ybid, info.source)
      crit_count.upsert(ybid, info.crit_count.to_s)
      list_count.upsert(ybid, info.addListTotal.to_s)
      word_count.upsert(ybid, info.word_count.to_s)
    rescue err
      puts "- error loading [#{ybid}]: #{err}".colorize.red
    end

    @seeding.save!

    extra_tags.save!
    source_url.save!
    crit_count.save!
    list_count.save!
    word_count.save!
  end

  def seed!
    # seed_intros.upsert!(ybid, data.intro, mtime: 0)
    # seed_covers.upsert!(ybid, data.cover_fixed, mtime: 0)

    # seed_genres.upsert!(ybid, data.genre, mtime: 0)
    # seed_labels.upsert!(ybid, data.tags_fixed.join("  "), mtime: 0)
    # seed_source.upsert!(ybid, data.source, mtime: 0)
    # seed_status.upsert!(ybid, data.status.to_s, mtime: 0)

    # seed_word_count.upsert!(ybid, data.word_count.to_s, mtime: 0)
  end
end

worker = Chivi::SeedInfoYousuu.new
worker.init! unless ARGV.includes?("-init")

worker.seed!
