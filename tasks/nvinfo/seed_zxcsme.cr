require "compress/gzip"
require "json"
require "myhtml"

require "../../src/_util/http_util"
require "../pgdata/init_nvinfo"

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

    _, btitle, author = HEAD_RE_1.match(heading.inner_text.strip)
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
    @snvids = Dir.children(TXT_DIR)
    @snvids.sort_by!(&.to_i)

    puts "[INPUT: #{@snvids.size} entries]"
  end

  def prep!
    @snvids.each_with_index(1) do |snvid, idx|
      link = "http://www.zxcs.me/post/#{snvid}"
      file = File.join(INP_DIR, "#{snvid}.html.gz")

      next if File.exists?(file)
      HttpUtil.load_html(link, file, lbl: "#{idx}/#{@snvids.size}")
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

      puts "\n- <http://www.zxcs.me/post/#{snvid}>".colorize.cyan
      parser = ZxcsmeParser.new(snvid, file)

      @seed.add!(parser, atime: atime)
      @seed.set_val!(:extras, snvid, read_chsize(snvid))

      scores = [Random.rand(30..100), Random.rand(50..65)]
      @seed.set_val!(:rating, snvid, scores.map(&.to_s))

      if idx % 100 == 0
        puts "- [zxcs.me]: <#{idx}/#{@snvids.size}>"
        @seed.save!(clean: false)
      end
    rescue err
      puts [snvid, err.message.colorize.red]
    end

    @seed.save!(clean: false)
  end

  def read_chsize(snvid : String) : Array(String)
    files = Dir.glob("#{TXT_DIR}/#{snvid}/*.tsv")
    flast = files.sort_by { |x| File.basename(x, ".tsv").to_i }.last

    lines = File.read_lines(flast).reject(&.blank?)
    last_chap = lines[-1].split('\t', 2)[0]

    [last_chap, last_chap]
  end

  PREV_FILE = "_db/zhbook/zxcs_me/prevs.json"

  # copy missing data (due to 404) from older data
  def inherit!(redo = false)
    atime = Time.utc(2019, 1, 1).to_unix.to_s

    inputs = Hash(String, ZxcsmeJson).from_json File.read(PREV_FILE)
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
    @seed._index.each do |_snvid, value|
      _atime, rtitle, author = value
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
    @seed._index.each do |_snvid, value|
      _atime, rtitle, author = value

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
            nvinfo: #{Nvinfo.query.count.colorize.cyan}"

    input.sort_by(&.[0].to_i).each_with_index(1) do |(snvid, values), idx|
      save_book(snvid, values)

      if idx % 100 == 0
        puts "- [zxcs_me/seed] <#{idx.colorize.cyan}/#{input.size}>, \
                authors: #{Author.query.count.colorize.cyan}, \
                nvinfo: #{Nvinfo.query.count.colorize.cyan}"
      end
    end

    puts "- authors: #{Author.query.count.colorize.cyan}, \
            nvinfo: #{Nvinfo.query.count.colorize.cyan}"
  end

  def save_book(snvid : String, values : Array(String), redo = false)
    bumped, p_ztitle, p_author = values
    return if p_ztitle.empty? || p_author.empty?

    author = SeedUtil.get_author(p_author, p_ztitle, force: true).not_nil!

    ztitle = BookUtils.fix_zh_btitle(p_ztitle, author.zname)
    nvinfo = Nvinfo.upsert!(author, ztitle)

    zhbook = Zhbook.upsert!("zxcs_me", snvid)
    bumped = bumped.to_i64

    if redo || zhbook.unmatch?(nvinfo.id)
      zhbook.nvinfo = nvinfo
      nvinfo.add_zhseed(zhbook.zseed)

      nvinfo.set_genres(@seed.get_genres(snvid))
      # nvinfo.set_bcover("zxcs_me-#{snvid}.webp")
      nvinfo.set_zintro(@seed.get_intro(snvid).join("\n"))

      if nvinfo.voters == 0
        voters, rating = @seed.get_scores(snvid)
        nvinfo.set_scores(voters, rating)
      end
    else # zhbook already created before
      return unless bumped > zhbook.bumped
    end

    zhbook.status = @seed.status.ival(snvid)
    nvinfo.set_status(zhbook.status)

    zhbook.bumped = bumped
    zhbook.mftime = @seed.mftime.ival_64(snvid)

    if zhbook.mftime < 1
      zhbook.mftime = nvinfo.mftime
    else
      nvinfo.set_mftime(zhbook.mftime)
    end

    if zhbook.chap_count == 0
      vals = @seed.chsize.get(snvid) || ["0", "0"]
      zhbook.chap_count = vals[0].to_i
      zhbook.last_schid = vals[1]
    end

    zhbook.save!
    nvinfo.save!
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
