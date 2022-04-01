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

      next unless atime = FileUtil.mtime_int(file)
      next unless redo || @seed.get_map(:_index, snvid).ival_64(snvid) < atime

      puts "\n- <http://www.zxcs.me/post/#{snvid}>".colorize.cyan
      parser = ZxcsmeParser.new(snvid, file)

      @seed.add!(parser, snvid, atime: atime)
      @seed.set_val!(:extras, snvid, read_chsize(snvid))

      scores = [Random.rand(30..100), Random.rand(50..65)]
      @seed.set_val!(:rating, snvid, scores.map(&.to_s))

      if idx % 100 == 0
        puts "- [zxcs.me]: <#{idx}/#{@snvids.size}>"
        @seed.save_stores!
      end
    rescue err
      puts [snvid, err.message.colorize.red]
    end

    @seed.save_stores!
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
    idx = 1

    @seed.stores[:_index].each_value do |map|
      map.data.each do |snvid, values|
        save_book(snvid, values)

        if idx % 100 == 0
          puts "- [zxcs_me/seed] <#{idx.colorize.cyan}/#{input.size}>, \
                authors: #{Author.query.count.colorize.cyan}, \
                nvinfo: #{Nvinfo.query.count.colorize.cyan}"
        end

        idx += 1
      end
    end

    puts "- authors: #{Author.query.count.colorize.cyan}, \
            nvinfo: #{Nvinfo.query.count.colorize.cyan}"
  end

  def save_book(snvid : String, values : Array(String), redo = false)
    bumped, p_btitle, p_author = values
    return if p_btitle.empty? || p_author.empty?
    f_btitle, f_author = BookUtil.fix_names(p_btitle, p_author)

    author = Author.upsert!(f_author)
    nvinfo = Nvinfo.upsert!(author, f_btitle)

    nvseed = Nvseed.upsert!("zxcs_me", snvid)
    bumped = bumped.to_i64

    if redo || nvseed.unmatch?(nvinfo.id)
      nvseed.nvinfo = nvinfo
      nvinfo.add_zhseed(nvseed.zseed)

      nvinfo.set_genres(@seed.get_genres(snvid))
      # nvinfo.set_bcover("zxcs_me-#{snvid}.webp")
      nvinfo.set_zintro(@seed.get_intro(snvid).join("\n"))

      if nvinfo.voters == 0
        voters, rating = @seed.get_scores(snvid)
        nvinfo.set_scores(voters, rating)
      end
    else # nvseed already created before
      return unless bumped > nvseed.bumped
    end

    nvseed.status = @seed.status.ival(snvid)
    nvinfo.set_status(nvseed.status)

    nvseed.bumped = bumped
    nvseed.mftime = @seed.mftime.ival_64(snvid)

    if nvseed.mftime < 1
      nvseed.mftime = nvinfo.mftime
    else
      nvinfo.set_mftime(nvseed.mftime)
    end

    if nvseed.chap_count == 0
      vals = @seed.chsize.get(snvid) || ["0", "0"]
      nvseed.chap_count = vals[0].to_i
      nvseed.last_schid = vals[1]
    end

    nvseed.save!
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
worker.fix_authors!
worker.fix_btitles!
worker.seed!
