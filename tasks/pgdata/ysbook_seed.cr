require "file_utils"
require "option_parser"

require "../../src/_init/init_nvinfo.cr"
require "../shared/bootstrap.cr"
require "../shared/ysbook_raw.cr"

class CV::YsbookSeed
  DIR = "_db/yousuu/infos"

  def initialize
    @seed = InitNvinfo.new("yousuu")
  end

  def init!(redo = false)
    dirs = Dir.children(DIR)
    dirs.each_with_index(1) do |dir, i|
      Log.info { "\n[[#{i}/#{dirs.size}]]\n".colorize.yellow }

      entries = Dir.glob("#{DIR}/#{dir}/*.json").map do |file|
        snvid = File.basename(file, ".json")
        atime = FileUtil.mtime(file).try(&.to_unix) || 0_i64
        {file, snvid, atime}
      end

      entries.sort_by!(&.[1].to_i)
      entries.each_with_index(1) do |(file, snvid, atime), idx|
        next unless redo || @seed.staled?(snvid, atime)
        entry = YsbookRaw.parse_file(file)
        @seed.add!(entry, snvid, atime)
      rescue err
        @seed.set_val!(:_index, snvid.not_nil!, [atime.to_s, "-", "-"])

        unless err.is_a?(YsbookRaw::InvalidFile)
          Log.error { "- error loading [#{snvid}]:" }
          Log.error { err.inspect_with_backtrace.colorize.red }
        end
      end

      @seed.save_stores!
    end
  end

  # def seed!(redo = false)
  #   snvids = @seed._index.data.keys

  #   puts "- Input: #{snvids.size.colorize.cyan} entries, \
  #         authors: #{Author.query.count.colorize.cyan}, \
  #         cvbooks: #{Cvbook.query.count.colorize.cyan}"

  #   snvids.each_with_index(1) do |snvid, idx|
  #     save_book(snvid, redo: redo)

  #     if idx % 100 == 0
  #       puts "- [ysbook/seed] <#{idx.colorize.cyan}/#{snvids.size}>, \
  #             authors: #{Author.query.count.colorize.cyan}, \
  #             cvbooks: #{Cvbook.query.count.colorize.cyan}"
  #     end
  #   end

  #   puts "- authors: #{Author.query.count.colorize.cyan}, \
  #           cvbooks: #{Cvbook.query.count.colorize.cyan}"
  # end

  # @checked = Set(String).new # skip checked if run twice

  # def save_book(snvid : String, redo = false) : Nil
  #   return if @checked.includes?(snvid)

  #   bumped, rtitle, author = @seed.get_index(snvid)
  #   list_count, crit_count, word_count = @seed.get_counts(snvid)
  #   force = list_count > 0 || crit_count > 3

  #   author = SeedUtil.get_author(author, rtitle, force: force)
  #   return unless author
  #   @checked.add(snvid)

  #   ztitle = BookUtils.fix_zh_btitle(rtitle, author.zname)
  #   ysbook = Ysbook.get!(snvid.to_i64)

  #   cvbook = Cvbook.upsert!(author, ztitle)

  #   if redo || ysbook.unmatch?(cvbook.id)
  #     ysbook.cvbook_id = cvbook.id
  #     # cvbook.set_bcover("yousuu-#{snvid}.webp")

  #     cvbook.set_genres(@seed.get_genres(snvid))
  #     cvbook.set_zintro(@seed.get_intro(snvid).join("\n"))
  #   else # ysbook already created before
  #     return unless bumped > ysbook.bumped
  #   end

  #   status, shield = @seed.get_status(snvid)
  #   cvbook.set_status(status)
  #   cvbook.set_shield(shield)

  #   ysbook.voters, ysbook.rating = @seed.get_scores(snvid)
  #   author.update_weight!(ysbook.voters * ysbook.rating)
  #   cvbook.set_scores(ysbook.voters, ysbook.rating)

  #   ysbook.bumped = bumped
  #   ysbook.mftime = @seed.get_mftime(snvid)
  #   cvbook.set_mftime(ysbook.mftime)

  #   ysbook.root_link, ysbook.root_name = @seed.get_origin(snvid)
  #   ysbook.list_count, ysbook.crit_count, _ = @seed.get_counts(snvid)

  #   ysbook.save!
  #   cvbook.save!
  # end

  def self.run!(argv = ARGV)
    redo = false
    twice = false

    OptionParser.parse(argv) do |opt|
      opt.on("-r", "Redo tasks") { redo = true }
      opt.on("-t", "Seed twice") { twice = true }
      opt.unknown_args { |x| argv = x }
    end

    seeder = new
    seeder.init!(redo: redo) if argv.includes?("init")
    # seeder.seed!
    # seeder.seed! if twice
  end
end

CV::YsbookSeed.run!
