require "file_utils"

require "../../src/filedb/*"
require "../../src/_seeds/yousuu_info"

class MapYousuu
  JSON_DIR = "_db/inits/seeds/yousuu/_infos"

  INIT_DIR = "_db/inits/seeds/yousuu/infos"
  FileUtils.mkdir_p(INIT_DIR)

  SEED_DIR = "_db/prime/serial/seeds/yousuu"
  FileUtils.mkdir_p(SEED_DIR)

  # all books

  getter init_atimes : ValueMap { load_init("atimes", @preload) }

  getter init_titles : ValueMap { load_init("titles", @preload) }
  getter init_authors : ValueMap { load_init("author", @preload) }

  getter init_voters : ValueMap { load_init("voters", @preload) }
  getter init_rating : ValueMap { load_init("rating", @preload) }
  getter init_mtimes : ValueMap { load_init("mtimes", @preload) }

  getter init_crit_count : ValueMap { load_init("crit_count", @preload) }
  getter init_list_count : ValueMap { load_init("list_count", @preload) }

  # picked books

  getter seed_bnames : ValueMap { load_seed("bnames", @preload) }
  getter seed_s_bids : ValueMap { load_seed("s_bids", @preload) }

  getter seed_intros : ValueMap { load_seed("intros", @preload) }
  getter seed_covers : ValueMap { load_seed("covers", @preload) }
  getter seed_genres : ValueMap { load_seed("genres", @preload) }
  getter seed_labels : ValueMap { load_seed("labels", @preload) }
  getter seed_status : ValueMap { load_seed("status", @preload) }
  getter seed_source : ValueMap { load_seed("source", @preload) }

  getter seed_word_count : ValueMap { load_seed("word_count", @preload) }

  getter author_wl = ValueMap.new("_db/inits/seeds/_keeps/author_wl.tsv")

  def initialize(@preload : Bool = true)
  end

  INFOS = {} of String => YousuuInfo

  INITS = {} of String => ValueMap
  SEEDS = {} of String => ValueMap

  def load_data(file : String, y_bid : String)
    INFOS[y_bid] ||= YousuuInfo.load(file)
  rescue err
    puts "- error loading [#{y_bid}]: #{err}".colorize.red
    nil
  end

  def load_init(type : String, preload = true) : ValueMap
    INITS[type] ||= ValueMap.new("#{INIT_DIR}/#{type}.tsv", preload)
  end

  def load_seed(type : String, preload = true) : ValueMap
    SEEDS[type] ||= ValueMap.new("#{SEED_DIR}/#{type}.tsv", preload)
  end

  def init!
    input = Dir.glob("#{JSON_DIR}/*.json")
    puts "- Input: #{input.size} files.".colorize.cyan

    input.each_with_index do |file, idx|
      y_bid = File.basename(file, ".json")

      atime = File.info(file).modification_time.to_unix
      next if init_atimes.get_value(y_bid).try(&.to_i64.> atime)
      init_atimes.upsert!(y_bid, atime.to_s, mtime: 0)

      next unless data = load_data(file, y_bid)
      puts "- <#{idx + 1}/#{input.size}> [#{data.title}  #{data.author}]".colorize.blue

      init_titles.upsert!(y_bid, data.title, mtime: 0)
      init_authors.upsert!(y_bid, data.author, mtime: 0)

      init_voters.upsert!(y_bid, data.voters.to_s, mtime: 0)
      init_rating.upsert!(y_bid, data.rating.to_s, mtime: 0)

      init_mtimes.upsert!(y_bid, data.updated_at.to_unix.to_s, mtime: 0)

      init_crit_count.upsert!(y_bid, data.crit_count.to_s, mtime: 0)
      init_list_count.upsert!(y_bid, data.addListTotal.to_s, mtime: 0)
    end
  end

  def seed!
    # seed_intros.upsert!(y_bid, data.intro, mtime: 0)
    # seed_covers.upsert!(y_bid, data.cover_fixed, mtime: 0)

    # seed_genres.upsert!(y_bid, data.genre, mtime: 0)
    # seed_labels.upsert!(y_bid, data.tags_fixed.join("  "), mtime: 0)
    # seed_source.upsert!(y_bid, data.source, mtime: 0)
    # seed_status.upsert!(y_bid, data.status.to_s, mtime: 0)

    # seed_word_count.upsert!(y_bid, data.word_count.to_s, mtime: 0)
  end

  def save!
    INITS.each_value(&.save!)
    SEEDS.each_value(&.save!)
  end
end

def main(argv : Array(String))
  worker = MapYousuu.new(preload: !argv.includes?("rebuild"))
  worker.init! unless argv.includes?("-init")

  worker.save!
end

main(ARGV)
