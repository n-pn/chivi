require "compress/gzip"
require "json"
require "myhtml"

require "../../src/cutil/http_utils"
require "../shared/seed_data"

class CV::ZxcsmeParser
  def initialize(@snvid : String, gz_file : String)
    html = File.open(gz_file) do |io|
      Compress::Gzip::Reader.open(io, &.gets_to_end)
    end

    @doc = Myhtml::Parser.new(html)
  end

  HEAD_RE_1 = /^《(.+)》.+作者[:：]\s*(.+)$/

  def parse!
    return unless heading = @doc.css("#content > h1").first?

    unless match = HEAD_RE_1.match(heading.inner_text.strip)
      puts "Unmatched regex!", heading
      exit(0)
    end

    _, btitle, author = match
    return {btitle, author}
  end

  getter bcover : String { @doc.css("#content img").first.attributes["src"] }

  getter bintro : Array(String) do
    @doc.css(".yinyong").each(&.remove!)

    if nodes = @doc.css("#content > p > span").first?
      bintro = nodes.inner_text("   ")
      return split_html(bintro).reject(&.empty?)
    end

    bintro = ""
    @doc.css("#content > p").each do |node|
      bintro = node.inner_text("   ")
      break if bintro.includes?("内容简介")
    end

    bintro = split_html(bintro).map do |line|
      case line
      when "【内容简介】：", " 内容简介：", .starts_with?("【TXT大小】")
        ""
      when .includes?("内容简介"), .includes?("简介：")
        puts line
        line.sub("【?内容简介】?：", "").sub(/.+ MB^/, "")
      else
        line
      end
    end

    bintro.map(&.strip).reject(&.empty?)
  end

  private def split_html(input : String)
    input.tr("　", " ").split(/\r\n?|\n|\s{2,}/).map(&.strip)
  end

  getter genres : Array(String) do
    genres = @doc.css("#content > .date > a").to_a.map(&.inner_text)
    genres.tap(&.shift?)
  end
end

class CV::ZxcsmeJson
  include JSON::Serializable

  property btitle : String
  property author : String

  property genres : Array(String)
  property bintro : Array(String)
  property bcover : String
end

class CV::SeedZxcsme
  INP_DIR = "_db/.cache/zxcs_me/infos"
  IDX_DIR = "_db/chseed/zxcs_me"

  getter snvids : Array(String)
  @seed = SeedData.new("zxcs_me")

  def initialize
    @snvids = Dir.children(IDX_DIR)
    @snvids.sort_by!(&.to_i)

    puts "[INPUT: #{@snvids.size} entries]"
  end

  def prep!
    @snvids.each_with_index(1) do |snvid, idx|
      file = File.join(INP_DIR, "#{snvid}.html.gz")
      next if File.exists?(file)

      link = "http://www.zxcs.me/post/#{snvid}"
      html = HttpUtils.get_html(link, label: "#{idx}/#{@snvids.size}")

      HttpUtils.save_html(file, html)
      sleep Random.rand(500).milliseconds
    rescue err
      puts err.colorize.red
    end
  end

  def init!(redo = false)
    @snvids.each_with_index(1) do |snvid, idx|
      file = File.join(INP_DIR, "#{snvid}.html.gz")

      next unless atime = SeedUtil.get_mtime(file)
      next unless redo || @seed._index.ival_64(snvid) < atime

      parser = ZxcsmeParser.new(snvid, file)

      puts "\n- <http://www.zxcs.me/post/#{snvid}>".colorize.cyan

      next unless result = parser.parse!
      btitle, author = result

      puts "- <#{idx}/#{@snvids.size}}> {#{snvid}} [#{btitle}  #{author}]"

      @seed._index.set!(snvid, [atime.to_s, btitle, author])

      @seed.set_intro(snvid, parser.bintro)
      @seed.genres.set!(snvid, parser.genres)
      @seed.bcover.set!(snvid, parser.bcover)

      status = author.ends_with?("【断更】") ? 2 : 1
      @seed.status.set!(snvid, status.to_s)

      @seed.chsize.set!(snvid, read_chsize(snvid))

      scores = [Random.rand(30..100), Random.rand(50..65)]
      @seed.scores.set!(snvid, scores.map(&.to_s))

      if idx % 100 == 0
        puts "- [zxcs.me]: <#{idx}/#{@snvids.size}>"
        @seed.save!(clean: false)
      end
    rescue err
      puts [snvid, err.message.colorize.red]
      gets
    end

    @seed.save!(clean: false)
  end

  def read_chsize(snvid : String) : Array(String)
    index_file = "#{IDX_DIR}/#{snvid}/_id.tsv"
    return ["0", ""] unless File.exists?(index_file)

    lines = File.read_lines(index_file).reject(&.blank?)
    [lines.size.to_s, lines.size.to_s.rjust(4, '0')]
  end

  # copy missing data (due to 404) from older data
  def inherit!(redo = false)
    atime = Time.utc(2019, 1, 1).to_unix.to_s

    inputs = Hash(String, ZxcsmeJson).from_json File.read("_db/zhbook/old-zxcs.json")
    inputs.each do |snvid, input|
      next if !redo && @seed._index.get(snvid)

      puts " - <#{snvid}> [#{input.btitle} #{input.author}]"

      @seed._index.set!(snvid, [atime, input.btitle, input.author])

      @seed.set_intro(snvid, input.bintro)
      @seed.genres.set!(snvid, input.genres)
      @seed.bcover.set!(snvid, input.bcover)

      status = input.author.ends_with?("【断更】") ? 2 : 1
      @seed.status.set!(snvid, status.to_s)

      @seed.chsize.set!(snvid, read_chsize(snvid))

      scores = [Random.rand(30..100), Random.rand(50..65)]
      @seed.scores.set!(snvid, scores.map(&.to_s))
    end

    @seed.save!(clean: false)
  end

  def fix_authors!
    @seed._index.each do |snvid, value|
      bumped, rtitle, author = value
      next if author.ends_with?("【断更】") # resolved
      next unless author =~ /[\(\[（【]/

      if fix_author = BookUtils.zh_authors.fval_alt("#{author}  #{rtitle}", author)
        puts "#{author} => #{fix_author}".colorize.green
        next
      end

      puts [rtitle, author].join('\t').colorize.red
    end
  end

  def fix_btitles!
    @seed._index.each do |snvid, value|
      bumped, rtitle, author = value

      next unless rtitle =~ /[\(\[（【]/
      author = BookUtils.fix_zh_author(author, rtitle)

      if ztitle = BookUtils.zh_btitles.fval_alt("#{rtitle}  #{author}", rtitle)
        puts "#{rtitle} => #{ztitle}".colorize.green
      else
        fix_btitle!(rtitle, author)
      end
    end
  end

  def fix_btitle!(rtitle : String, author : String)
    _, title1, title2 = rtitle.match(/^(.+)[\(\[（【](.+)[）】\)\]]$/).not_nil!
    puts "\n#{title1} | #{title2}   #{author}".colorize.red
    puts " - #{gen_ys_title_search(title1)}"
    puts " - #{gen_ys_title_search(title2)}"
    print "   Pick (1*: t1 + auth, 2: t2 + auth, 3: t1, 4: t2): "

    keep, key1, key2 =
      case gets
      when "1" then {title1, "#{title2}  #{author}", "#{rtitle}  #{author}"}
      when "2" then {title2, "#{title1}  #{author}", "#{rtitle}  #{author}"}
      when "3" then {title1, title2, rtitle}
      when "4" then {title2, title1, rtitle}
      else          {title1, "#{title2}  #{author}", "#{rtitle}  #{author}"}
      end

    BookUtils.zh_btitles.set!(key2, keep)
    BookUtils.zh_btitles.set!(key1, keep)
    BookUtils.zh_btitles.save!
  end

  def seed!
    input = @seed._index.data.to_a

    puts "- Input: #{input.size.colorize.cyan} entries, \
            authors: #{Author.query.count.colorize.cyan}, \
            cvbooks: #{Cvbook.query.count.colorize.cyan}"

    input.sort_by(&.[0].to_i).each_with_index(1) do |(snvid, values), idx|
      save_book(snvid, values)

      if idx % 100 == 0
        puts "- [zxcs_me/seed] <#{idx.colorize.cyan}/#{input.size}>, \
                authors: #{Author.query.count.colorize.cyan}, \
                cvbooks: #{Cvbook.query.count.colorize.cyan}"
      end
    end

    puts "- authors: #{Author.query.count.colorize.cyan}, \
            cvbooks: #{Cvbook.query.count.colorize.cyan}"
  end

  def save_book(snvid : String, values : Array(String), redo = false)
    bumped, p_ztitle, p_author = values
    return if p_ztitle.empty? || p_author.empty?

    author = SeedUtil.get_author(p_author, p_ztitle, force: true).not_nil!

    ztitle = BookUtils.fix_zh_btitle(p_ztitle, author.zname)
    cvbook = Cvbook.upsert!(author, ztitle)

    zhbook = Zhbook.upsert!("zxcs_me", snvid)
    bumped = bumped.to_i64

    if redo || zhbook.unmatch?(cvbook.id)
      zhbook.cvbook = cvbook
      cvbook.add_zhseed(zhbook.zseed)

      cvbook.set_genres(@seed.get_genres(snvid))
      cvbook.set_bcover("zxcs_me-#{snvid}.webp")
      cvbook.set_zintro(@seed.get_intro(snvid).join("\n"))

      if cvbook.voters == 0
        voters, rating = @seed.get_scores(snvid)
        cvbook.set_scores(voters, rating)
      end
    else # zhbook already created before
      return unless bumped > zhbook.bumped
    end

    zhbook.status = @seed.status.ival(snvid)
    cvbook.set_status(zhbook.status)

    zhbook.bumped = bumped
    zhbook.mftime = @seed.mftime.ival_64(snvid)

    if zhbook.mftime < 1
      zhbook.mftime = cvbook.mftime
    else
      cvbook.set_mftime(zhbook.mftime)
    end

    if zhbook.chap_count == 0
      vals = @seed.chsize.get(snvid) || ["0", "0"]
      zhbook.chap_count = vals[0].to_i
      zhbook.last_schid = vals[1]
    end

    zhbook.save!
    cvbook.save!
  end

  private def gen_ys_title_search(title : String)
    "https://www.yousuu.com/search/?search_type=title&search_value=#{title}"
  end
end

worker = CV::SeedZxcsme.new
worker.prep! if ARGV.includes?("prep")
worker.init!
worker.inherit!
# worker.fix_authors!
# worker.fix_btitles!
worker.seed!
