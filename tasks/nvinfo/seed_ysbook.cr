require "file_utils"
require "option_parser"

require "../shared/seed_util.cr"
require "../shared/ysbook_og.cr"

class CV::SeedYsbook
  DIR = "_db/yousuu/.cache/infos"

  @index = SeedUtil.load_map("yousuu/_index")

  def seed!(redo = false)
    queue = Dir.glob("#{DIR}/*.json").sort_by do |file|
      File.basename(file, ".json").to_i
    end

    puts "- Input: #{queue.size.colorize.cyan} entries, \
          authors: #{Author.count.colorize.cyan}, \
          btitles: #{Cvbook.count.colorize.cyan}"

    queue.each_with_index(1) do |file, idx|
      if idx % 100 == 0
        @index.save!(clean: false)
        puts "- [ysbook] <#{idx.colorize.cyan}/#{queue.size}>, \
              authors: #{Author.count.colorize.cyan}, \
              btitles: #{Cvbook.count.colorize.cyan}"
      end

      snvid = File.basename(file, ".json")
      bumped = SeedUtil.get_mtime(file)
      next unless redo || @index.ival_64(snvid) < bumped

      next unless puller = YsbookOg.load(file)
      seed_item(puller, bumped)

      @index.set!(snvid, [bumped.to_s, puller.title, puller.author])
    rescue err
      puts err.inspect_with_backtrace.colorize.red
    end

    @index.save!(clean: true)
    puts "- authors: #{Author.count.colorize.cyan}, \
            btitles: #{Cvbook.count.colorize.cyan}"
  end

  def seed_item(puller : YsbookOg, bumped : Int64) : Nil
    btitle, force = puller.title, puller.decent?
    author = SeedUtil.get_author(puller.author, btitle, force: force)

    return unless author
    author.update_weight!(puller.voters * puller.rating)

    ztitle = BookUtils.fix_zh_btitle(btitle, author.zname)
    ysbook = Ysbook.get!(puller._id.to_i64)

    ysbook.author = author.zname
    ysbook.ztitle = ztitle

    cvbook = Cvbook.upsert!(author, ztitle)
    ysbook.cvbook = cvbook

    ysbook.genres = puller.genres
    cvbook.set_genres(puller.genres)

    ysbook.bcover = puller.cover_fixed
    cvbook.set_bcover("yousuu-#{puller._id}.webp")

    ysbook.bintro = puller.intro.join("\n")
    cvbook.set_zintro(ysbook.bintro)

    ysbook.status = puller.status
    cvbook.set_status(puller.status)

    ysbook.shield = puller.shielded ? 1 : 0
    cvbook.set_shield(ysbook.shield)

    ysbook.bumped = bumped
    ysbook.mftime = puller.updated_at.to_unix
    cvbook.set_mftime(ysbook.mftime)

    ysbook.voters = puller.voters
    ysbook.rating = puller.rating
    cvbook.set_scores(ysbook.voters, ysbook.rating)

    ysbook.word_count = puller.word_count
    ysbook.crit_count = puller.commentCount
    ysbook.list_count = puller.addListTotal

    ysbook.root_link = puller.root_link
    ysbook.root_name = puller.root_name

    ysbook.save!
    cvbook.save!
  rescue err
    snvid = puller._id.to_s
    @index.set!(snvid, [bumped.to_s, "-", "-"])

    unless err.is_a?(YsbookOg::InvalidFile)
      puts "- error loading [#{snvid}]:"
      puts err.inspect_with_backtrace.colorize.red
    end
  end

  def self.run!(argv = ARGV)
    redo = false

    OptionParser.parse(ARGV) do |opt|
      opt.on("-a", "Ignore indexes") { redo = true }
    end

    seeder = new
    seeder.seed!(redo: redo)
  end
end

CV::SeedYsbook.run!
