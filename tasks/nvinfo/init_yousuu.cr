require "file_utils"

require "../shared/fs_ysbook.cr"
require "../shared/bootstrap.cr"

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
      if idx % 100 == 0
        puts "- [yousuu] <#{idx}/#{queue.size}>".colorize.cyan
        @seed.save!(clean: false)
      end

      snvid = File.basename(file, ".json")
      atime = SeedUtil.get_mtime(file)

      next if @seed._index.ival_64(snvid) >= atime
      next unless json = FsYsbook.load(file)


      book = Ysbook.get!(snvid.to_i64)

      book.author = json.author
      book.ztitle = json.title

      book.genres = json.genres
      book.bintro = json.intro.join("\n")
      book.bcover = json.cover_fixed

      book.status = json.status
      book.shield = json.shielded ? 1 : 0

      book.bumped = atime
      book.mftime = json.updated_at.to_unix

      book.voters = json.voters
      book.rating = json.rating

      book.word_count = json.word_count
      book.crit_count = json.commentCount
      book.list_count = json.addListTotal

      book.root_link = json.root_link
      # TODO: parse root_name

      book.save!
      @seed._index.set!(snvid, [atime.to_s, json.title, json.author])
    rescue err
      puts "- error loading [#{snvid}]: ".colorize.red
      puts err.inspect_with_backtrace.colorize.red
    end

    @seed.save!(clean: true)
  end
end

worker = CV::InitYousuu.new
worker.parse!
