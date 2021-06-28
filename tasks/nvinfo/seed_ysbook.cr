require "file_utils"
require "option_parser"

require "../shared/seed_util.cr"
require "../shared/ysbook_og.cr"

class CV::SeedYsbook
  DIR = "_db/yousuu/.cache/infos"

  @index = SeedUtil.load_map("yousuu/_index")

  def seed!(redo = false)
    input = Dir.glob("#{DIR}/*.json").map do |file|
      snvid = File.basename(file, ".json")
      bumped = SeedUtil.get_mtime(file)
      {file, snvid, bumped}
    end

    puts "- Input: #{input.size.colorize.cyan} entries, \
          authors: #{Author.count.colorize.cyan}, \
          cvbooks: #{Cvbook.count.colorize.cyan}"

    input = input.sort_by(&.[1].to_i)

    input.each_with_index(1) do |(yfile, snvid, bumped), idx|
      next unless redo || @index.ival_64(snvid) < bumped
      puller = YsbookOg.load(yfile)

      save_book(puller, bumped)
      @index.set!(snvid, [bumped.to_s, puller.title, puller.author])

      if idx % 100 == 0
        @index.save!(clean: false)
        puts "- [ysbook] <#{idx.colorize.cyan}/#{input.size}>, \
              authors: #{Author.count.colorize.cyan}, \
              cvbooks: #{Cvbook.count.colorize.cyan}"
      end
    rescue err
      @index.set!(snvid.not_nil!, [bumped.not_nil!.to_s, "-", "-"])

      unless err.is_a?(YsbookOg::InvalidFile)
        puts "- error loading [#{snvid}]:"
        puts err.inspect_with_backtrace.colorize.red
      end
    end

    @index.save!(clean: true)
    puts "- authors: #{Author.count.colorize.cyan}, \
            cvbooks: #{Cvbook.count.colorize.cyan}"
  end

  def save_book(puller : YsbookOg, bumped : Int64, dry = true) : Nil
    btitle, force = puller.title, puller.decent?

    author = SeedUtil.get_author(puller.author, btitle, force: force)

    return unless author
    author.update_weight!(puller.voters * puller.rating)

    ztitle = BookUtils.fix_zh_btitle(btitle, author.zname)
    ysbook = Ysbook.get!(puller._id.to_i64)

    cvbook = Cvbook.upsert!(author, ztitle)

    if dry && ysbook.cvbook_id == cvbook.id # ysbook already created before
      return unless bumped > ysbook.bumped  # return unless source updated
    else
      ysbook.cvbook = cvbook
      ysbook.author = author.zname
      ysbook.ztitle = ztitle

      ysbook.bcover = puller.cover_fixed # I doubt that cover_url change that much
      cvbook.set_bcover("yousuu-#{puller._id}.webp")

      ysbook.root_link = puller.root_link
      ysbook.root_name = puller.root_name

      ysbook.genres = puller.genres
      cvbook.set_genres(ysbook.genres)

      ysbook.bintro = puller.intro.join("\n")
      cvbook.set_zintro(ysbook.bintro)
    end

    ysbook.status = puller.status
    cvbook.set_status(ysbook.status)

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

    ysbook.save!
    cvbook.save!
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
