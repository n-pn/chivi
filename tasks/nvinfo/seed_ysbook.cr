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

      next unless ysbook = save_ysbook(file, bumped)
      save_btitle(ysbook)

      @index.set!(snvid, [bumped.to_s, ysbook.ztitle, ysbook.author])
    rescue err
      puts err.inspect_with_backtrace.colorize.red
    end

    @index.save!(clean: true)
    puts "- authors: #{Author.count.colorize.cyan}, \
            btitles: #{Cvbook.count.colorize.cyan}"
  end

  def save_ysbook(file : String, bumped = SeedUtil.get_mtime(file)) : Ysbook?
    input = YsbookOg.load(file)
    output = Ysbook.get!(input._id.to_i64)

    output.cvbook_id ||= 0

    output.author = input.author
    output.ztitle = input.title

    output.genres = input.genres
    output.bintro = input.intro.join("\n")
    output.bcover = input.cover_fixed

    output.status = input.status
    output.shield = input.shielded ? 1 : 0

    output.bumped = bumped
    output.mftime = input.updated_at.to_unix

    output.voters = input.voters
    output.rating = input.rating

    output.word_count = input.word_count
    output.crit_count = input.commentCount
    output.list_count = input.addListTotal

    output.root_link = input.root_link
    output.root_name = input.root_name

    output.tap(&.save!)
  rescue err
    snvid = File.basename(file, ".json")
    @index.set!(snvid, [bumped.to_s, "-", "-"])

    unless err.is_a?(YsbookOg::InvalidFile)
      puts "- error loading [#{snvid}]:"
      puts err.inspect_with_backtrace.colorize.red
    end
  end

  def save_btitle(ysbook : Ysbook) : Cvbook?
    author = SeedUtil.get_author(ysbook.author, ysbook.ztitle, ysbook.decent?)
    return unless author

    author.update_weight!(ysbook.voters * ysbook.rating)

    ztitle = BookUtils.fix_zh_btitle(ysbook.ztitle, author.zname)
    cvbook = Cvbook.upsert!(author, ztitle)

    ysbook.update!(btitle_id: cvbook.id)

    cvbook.set_genres(ysbook.genres)
    cvbook.set_bcover("yousuu-#{ysbook.id}.webp")
    cvbook.set_zintro(ysbook.bintro)

    cvbook.set_mftime(ysbook.mftime)
    cvbook.set_shield(ysbook.shield)
    cvbook.set_status(ysbook.status)

    cvbook.set_scores(ysbook.voters, ysbook.rating)

    cvbook.tap(&.save!)
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
