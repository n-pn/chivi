require "compress/gzip"
require "json"
require "myhtml"

require "../../src/_util/http_util"
require "../../src/_util/file_util"
require "./init_nvinfo"

class CV::ZxcsmeParser
  def initialize(@snvid : String, gz_file : String)
    html = File.open(gz_file) do |io|
      Compress::Gzip::Reader.open(io, &.gets_to_end)
    end

    @doc = Myhtml::Parser.new(html)
  end

  HEAD_RE_1 = /^《(.+)》.+作者[:：]\s*(.+)$/

  getter bnames : {String, String} do
    heading = @doc.css("#content > h1").first

    _, btitle, author = HEAD_RE_1.match(heading.inner_text.strip).not_nil!
    {btitle, author}
  end

  getter btitle : String { bnames[0] }
  getter author : String { bnames[1] }

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

  getter status : {Int32, String} do
    author.ends_with?("【断更】") ? {2, "【断更】"} : {1, ""}
  end
end

class CV::ZxcsmeJson
  include JSON::Serializable

  property btitle : String
  property author : String

  property genres : Array(String)
  property bintro : Array(String)
  property bcover : String?
end

class CV::SeedZxcsme
  INP_DIR = "_db/.cache/zxcs_me/infos"
  TXT_DIR = "var/chtexts/zxcs_me"

  getter snvids : Array(String)
  @seed = InitNvinfo.new("zxcs_me")

  def initialize
    @snvids = Dir.glob("#{TXT_DIR}/_/*.tsv").map { |x| File.basename(x, ".tsv") }
    @snvids.sort_by!(&.to_i)

    puts "[INPUT: #{@snvids.size} entries]"
  end

  def prep!
    @snvids.reverse.each_with_index(1) do |snvid, idx|
      link = "http://www.zxcs.me/post/#{snvid}"
      file = File.join(INP_DIR, "#{snvid}.html.gz")

      next if File.exists?(file)
      HttpUtil.load_html(link, file, lbl: "#{idx}/#{@snvids.size}")
    rescue err
      puts err.colorize.red
    end
  end

  def init!(redo = false)
    @snvids.each_with_index(1) do |snvid, idx|
      file = File.join(INP_DIR, "#{snvid}.html.gz")

      next unless atime = FileUtil.mtime_int(file)
      next unless redo || @seed.get_map(:_index, snvid).ival_64(snvid) < atime

      puts "\n- <http://www.zxcs.me/post/#{snvid}>".colorize.cyan
      parser = ZxcsmeParser.new(snvid, file)

      @seed.set_val!(:extras, snvid, read_chsize(snvid))
      @seed.add!(parser, snvid, atime: atime)

      if idx % 100 == 0
        puts "- [zxcs.me]: <#{idx}/#{@snvids.size}>"
        @seed.save_stores!
      end
    rescue err
      puts snvid, err.inspect_with_backtrace
    end

    @seed.save_stores!
  end

  def read_chsize(snvid : String) : Array(String)
    files = Dir.glob("#{TXT_DIR}/#{snvid}/*.tsv")
    return ["0", ""] if files.empty?

    flast = files.sort_by { |x| File.basename(x, ".tsv").to_i }.last

    lines = File.read_lines(flast).reject(&.blank?)
    last_chap = lines[-1].split('\t', 2)[0]

    [last_chap, last_chap]
  end

  PREV_FILE = "var/nvseeds/zxcs_me/prevs.json"

  # copy missing data (due to 404) from older data
  def inherit!(redo = false)
    atime = Time.utc(2019, 1, 1).to_unix.to_s

    inputs = Hash(String, ZxcsmeJson).from_json File.read(PREV_FILE)
    inputs.each do |snvid, input|
      next if !redo && @seed.get_map(:_index, snvid).get(snvid)

      puts " - <#{snvid}> [#{input.btitle} #{input.author}]"

      @seed.set_val!(:_index, snvid, [atime, input.btitle, input.author])

      @seed.set_val!(:intros, snvid, input.bintro)
      @seed.set_val!(:genres, snvid, input.genres)
      @seed.set_val!(:covers, snvid, input.bcover)

      status = input.author.ends_with?("【断更】") ? 2 : 1
      @seed.set_val!(:status, snvid, status.to_s)

      @seed.set_val!(:extras, snvid, read_chsize(snvid))

      scores = [Random.rand(30..100), Random.rand(50..65)]
      @seed.set_val!(:rating, snvid, scores.map(&.to_s))
    end

    @seed.save_stores!
  end

  def fix_authors!
    @seed.each_index do |rtitle, author|
      next if author.ends_with?("【断更】") # resolved
      next unless author =~ /[\(\[（【]/

      if fix_author = BookUtil.zh_authors.fval_alt("#{author}  #{rtitle}", author)
        puts "#{author} => #{fix_author}".colorize.green
        next
      end

      puts [rtitle, author].join('\t').colorize.red
    end
  end

  def fix_btitles!
    @seed.each_index do |rtitle, author|
      next unless rtitle =~ /[\(\[（【]/
      author = BookUtil.fix_name(:author, "#{author}  #{rtitle}", author)

      if ztitle = BookUtil.zh_btitles.fval_alt("#{rtitle}  #{author}", rtitle)
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

    BookUtil.zh_btitles.set!(key2, keep)
    BookUtil.zh_btitles.set!(key1, keep)
    BookUtil.zh_btitles.save!
  end

  def seed!
    @seed.seed_all!(false)
  end

  private def gen_ys_title_search(title : String)
    "https://www.yousuu.com/search/?search_type=title&search_value=#{title}"
  end
end

worker = CV::SeedZxcsme.new
worker.prep! if ARGV.includes?("prep")
worker.init!
worker.inherit!

if ARGV.includes?("fixes")
  worker.fix_authors!
  worker.fix_btitles!
end

worker.seed!
