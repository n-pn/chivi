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

  def resolve_poor_format_author
    map_author = Hash(String, Set(String)).new { |h, k| h[k] = Set(String).new }
    map_btitle = Hash(String, Set(String)).new { |h, k| h[k] = Set(String).new }

    fix_author = ValueMap.new("db/nv_fixes/author_zh.tsv")

    @seed._index.data.each do |snvid, value|
      voters = @seed.rating.ival(snvid)
      next if voters = 0

      _, title, author = value
      map_btitle[author] << title
      map_author[sanitize_author(author)] << author
    end

    map_author.each do |fixed, authors|
      authors = authors.reject do |a|
        a =~ /^ |(\.QD)|(\.CS)|\)|）|\s$/ || a.includes?("最新更新") || fix_author.has_key?(a)
      end

      next if authors.empty?

      if authors.size > 1
        # puts "- [#{fixed}] <== #{authors.to_a}".colorize.red
        # print "(1: keep 1, 2: keep 2, other: skip): "

        # case getch
        # when '1' then fix_author.set!(authors[1], authors[0])
        # when '2' then fix_author.set!(authors[0], authors[1])
        # when 'c' then break
        # end
        # puts
      elsif authors.first != fixed
        puts "- [#{fixed}] <== [#{authors.first}]".colorize.light_red
      end
    end

    fix_author.save!
  end

  def sanitize_author(author : String)
    # author = author.gsub(/^[^\p{Han}\p{Hiragana}\p{Katakana}\p{L}\p{N}_]/, "")
    # author = author.gsub(/[^\p{Han}\p{Hiragana}\p{Katakana}\p{L}\p{N}_.·]$/, "")

    author.strip
  end

  def getch
    STDIN.flush
    STDIN.raw &.read_char
  end
end

worker = CV::InitYousuu.new
worker.resolve_poor_format_author
# worker.parse!
