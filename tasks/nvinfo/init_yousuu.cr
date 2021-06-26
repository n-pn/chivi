require "file_utils"
require "option_parser"

require "../shared/bootstrap.cr"
require "../shared/ysbook_og.cr"

require "./shared/seed_data.cr"
require "./shared/seed_util.cr"

class CV::InitYousuu
  DIR = "_db/yousuu/.cache/infos"

  @seed = SeedData.new("yousuu")

  alias Result = Tuple(String, Array(String))

  def seed!(redo = false, workers = 16)
    queue = Dir.glob("#{DIR}/*.json").sort_by do |file|
      File.basename(file, ".json").to_i
    end

    puts "- Input: #{queue.size.colorize.cyan} entries, \
          authors: #{Author.count.colorize.cyan}, \
          btitles: #{Btitle.count.colorize.cyan}"

    queue.each_with_index(1) do |file, idx|
      if idx % 100 == 0
        puts "- [yousuu] <#{idx.colorize.cyan}/#{queue.size}>, \
              authors: #{Author.count.colorize.cyan}, \
              btitles: #{Btitle.count.colorize.cyan}"

        @seed._index.save!(clean: false)
      end

      atime = SeedUtil.get_mtime(file)
      snvid = File.basename(file, ".json")
      next unless redo || @seed._index.ival_64(snvid) < atime

      next unless ysbook = save_ysbook(file, atime)
      save_btitle(ysbook)

      @seed._index.set!(snvid, [atime.to_s, ysbook.ztitle, ysbook.author])
    rescue err
      puts err.inspect_with_backtrace.colorize.red
    end

    @seed._index.save!(clean: true)
    puts "- authors: #{Author.count.colorize.cyan}, \
            btitles: #{Btitle.count.colorize.cyan}"
  end

  def save_index(ysbook : Ysbook?)
    return unless ysbook
  end

  def save_ysbook(id : Int32)
    save_ysbook("#{DIR}/#{id}.json")
  end

  def save_ysbook(file : String, atime = SeedUtil.get_mtime(file)) : Ysbook?
    input = YsbookOg.load(file)
    output = Ysbook.get!(input._id.to_i64)

    output.author = input.author
    output.ztitle = input.title

    output.genres = input.genres
    output.bintro = input.intro.join("\n")
    output.bcover = input.cover_fixed

    output.status = input.status
    output.shield = input.shielded ? 1 : 0

    output.bumped = atime
    output.mftime = input.updated_at.to_unix

    output.voters = input.voters
    output.rating = input.rating

    output.word_count = input.word_count
    output.crit_count = input.commentCount
    output.list_count = input.addListTotal

    output.root_link = input.root_link
    # TODO: parse root_name

    output.tap(&.save!)
  rescue err
    snvid = File.basename(file, ".json")
    @seed._index.set!(snvid, [atime.to_s, "-", "-"])

    unless err.is_a?(YsbookOg::InvalidFile)
      puts "- error loading [#{snvid}]:"
      puts err.inspect_with_backtrace.colorize.red
    end
  end

  getter authors_map : Hash(String, Author) do
    Author.all.to_h { |x| {x.zname, x} }
  end

  def get_author(ysbook : Ysbook) : Author?
    zname = BookUtils.fix_zh_author(ysbook.author, ysbook.ztitle)
    authors_map[zname] ||= begin
      return unless ysbook.decent?
      Author.upsert!(zname)
    end
  end

  def save_btitle(ysbook : Ysbook) : Btitle?
    return unless author = get_author(ysbook)
    author.update_weight!(ysbook.voters * ysbook.rating)

    ztitle = BookUtils.fix_zh_btitle(ysbook.ztitle, author.zname)
    nvinfo = Btitle.upsert!(author, ztitle)

    ysbook.update!(btitle_id: nvinfo.id)

    nvinfo.set_genres(ysbook.genres)
    nvinfo.set_bcover("yousuu-#{ysbook.id}.jpg")
    nvinfo.set_zintro(ysbook.bintro)

    nvinfo.set_mftime(ysbook.mftime)
    nvinfo.set_shield(ysbook.shield)
    nvinfo.set_status(ysbook.status)

    nvinfo.set_scores(ysbook.voters, ysbook.rating)

    nvinfo.tap(&.save!)
  end
end

redo = false
workers = 10

OptionParser.parse(ARGV) do |opt|
  opt.on("-a", "Ignore indexes") { redo = true }
  opt.on("-w WORKERS", "Ignore indexes") { |x| workers = x.to_i }
end

worker = CV::InitYousuu.new
worker.seed!(redo: redo, workers: workers)
