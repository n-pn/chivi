require "file_utils"

require "../../src/seeds/ys_book"
require "./shared/seed_data.cr"
require "./shared/seed_util.cr"

class CV::InitYousuu
  @seed = SeedData.new("yousuu")

  def parse!
    queue = Dir.glob("_db/yousuu/.cache/infos/*.json").sort_by do |file|
      File.basename(file, ".json").to_i
    end

    puts "- Input: #{queue.size} entries".colorize.cyan

    queue.each_with_index(1) do |file, idx|
      snvid = File.basename(file, ".json")
      atime = SeedUtil.get_mtime(file)

      next if @seed._index.ival_64(snvid) >= atime
      next unless info = YsBook.load(file)

      @seed._index.set!(snvid, [atime.to_s, info.title, info.author])
      @seed.set_intro(snvid, info.intro)

      @seed.genres.set!(snvid, [info.genre].concat(info.tags_fixed).uniq)
      @seed.bcover.set!(snvid, info.cover_fixed)

      @seed.status.set!(snvid, info.status.to_s)
      @seed.update.set!(snvid, info.updateAt)

      @seed.hidden.set!(snvid, info.shielded ? "1" : "0")
      @seed.rating.set!(snvid, [info.voters.to_s, info.rating.to_s])

      @seed.source_url.set!(snvid, info.source)
      @seed.count_word.set!(snvid, info.word_count)
      @seed.count_crit.set!(snvid, info.crit_count)
      @seed.count_list.set!(snvid, info.addListTotal)

      if idx % 100 == 0
        puts "- [yousuu] <#{idx}/#{queue.size}>".colorize.cyan
        @seed.save!(clean: false)
      end
    rescue err
      puts "- error loading [#{snvid}]: #{err}".colorize.red
    end

    @seed.save!(clean: true)
  end
end

worker = CV::InitYousuu.new
worker.parse!
