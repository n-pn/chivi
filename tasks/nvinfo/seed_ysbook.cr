require "file_utils"
require "option_parser"

require "../shared/seed_data.cr"
require "../shared/raw_ysbook.cr"

class CV::SeedYsbook
  DIR = "_db/yousuu/.cache/infos"

  @seed = SeedData.new("yousuu")

  def init!(redo = false)
    input = read_dir(DIR).sort_by!(&.[1].to_i)

    input.each_with_index(1) do |(yfile, snvid, bumped), idx|
      next unless redo || @seed._index.ival_64(snvid) < bumped
      parser = RawYsbook.load(yfile)

      @seed._index.set!(snvid, [bumped.to_s, parser.title, parser.author])

      @seed.set_intro(snvid, parser.bintro)
      @seed.genres.set!(snvid, parser.genres)
      @seed.bcover.set!(snvid, parser.bcover)

      @seed.status.set!(snvid, [parser.status.to_s, parser.shield.to_s])
      @seed.mftime.set!(snvid, parser.updated_at.to_unix.to_s)

      @seed.scores.set!(snvid, [parser.voters.to_s, parser.rating.to_s])
      counted = [parser.addListTotal, parser.commentCount, parser.word_count]
      @seed.counts.set!(snvid, counted.map(&.to_s))
      @seed.origin.set!(snvid, [parser.root_link, parser.root_name])

      if idx % 100 == 0
        @seed.save!(clean: false)
        puts "- [ysbook/init] <#{idx.colorize.cyan}/#{input.size}>"
      end
    rescue err
      @seed._index.set!(snvid.not_nil!, [bumped.not_nil!.to_s, "-", "-"])

      unless err.is_a?(RawYsbook::InvalidFile)
        puts "- error loading [#{snvid}]:"
        puts err.inspect_with_backtrace.colorize.red
      end
    end

    @seed.save!(clean: false)
  end

  private def read_dir(dir = DIR)
    Dir.glob("#{DIR}/*.json").map do |file|
      snvid = File.basename(file, ".json")
      bumped = SeedUtil.get_mtime(file)
      {file, snvid, bumped}
    end
  end

  def seed!(redo = false)
    snvids = @seed._index.data.keys

    puts "- Input: #{snvids.size.colorize.cyan} entries, \
          authors: #{Author.query.count.colorize.cyan}, \
          cvbooks: #{Cvbook.query.count.colorize.cyan}"

    snvids.each_with_index(1) do |snvid, idx|
      save_book(snvid, redo: redo)

      if idx % 100 == 0
        puts "- [ysbook/seed] <#{idx.colorize.cyan}/#{snvids.size}>, \
              authors: #{Author.query.count.colorize.cyan}, \
              cvbooks: #{Cvbook.query.count.colorize.cyan}"
      end
    end

    puts "- authors: #{Author.query.count.colorize.cyan}, \
            cvbooks: #{Cvbook.query.count.colorize.cyan}"
  end

  def save_book(snvid : String, redo = false) : Nil
    bumped, rtitle, author = @seed.get_index(snvid)
    list_count, crit_count, word_count = @seed.get_counts(snvid)
    force = list_count > 0 || crit_count > 3

    author = SeedUtil.get_author(author, rtitle, force: force)
    return unless author

    ztitle = BookUtils.fix_zh_btitle(rtitle, author.zname)
    ysbook = Ysbook.get!(snvid.to_i64)

    cvbook = Cvbook.upsert!(author, ztitle)

    if redo || ysbook.unmatch?(cvbook.id)
      ysbook.cvbook_id = cvbook.id
      cvbook.set_bcover("yousuu-#{snvid}.webp")

      cvbook.set_genres(@seed.get_genres(snvid))
      cvbook.set_zintro(@seed.get_intro(snvid).join("\n"))
    else # ysbook already created before
      return unless bumped > ysbook.bumped
    end

    status, shield = @seed.get_status(snvid)
    cvbook.set_status(status)
    cvbook.set_shield(shield)

    ysbook.voters, ysbook.rating = @seed.get_scores(snvid)
    author.update_weight!(ysbook.voters * ysbook.rating)
    cvbook.set_scores(ysbook.voters, ysbook.rating)

    ysbook.bumped = bumped
    ysbook.mftime = @seed.get_mftime(snvid)
    cvbook.set_mftime(ysbook.mftime)

    ysbook.root_link, ysbook.root_name = @seed.get_origin(snvid)
    ysbook.list_count, ysbook.crit_count, _ = @seed.get_counts(snvid)

    ysbook.save!
    cvbook.save!
  end

  def self.run!(argv = ARGV)
    redo = false

    OptionParser.parse(ARGV) do |opt|
      opt.on("-a", "Ignore indexes") { redo = true }
    end

    seeder = new
    seeder.init!(redo: redo)
    seeder.seed!
  end
end

CV::SeedYsbook.run!
