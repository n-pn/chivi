require "file_utils"
require "compress/gzip"
require "json"
require "myhtml"

require "../../src/cutil/http_utils"
require "./shared/*"

class CV::ZxcsMeInfoParser
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

class CV::ZxcsMeJson
  include JSON::Serializable

  property btitle : String
  property author : String
  property bintro : Array(String)
  property genres : Array(String)
end

class CV::InitZxcsMe
  INP_DIR = "_db/.cache/zxcs_me/infos"
  IDX_DIR = "_db/ch_infos/origs/zxcs_me"

  ::FileUtils.mkdir_p(INP_DIR)

  getter snvids : Array(String)
  @seed = SeedData.new("zxcs_me")

  def initialize
    @snvids = Dir.glob("#{IDX_DIR}/*.tsv").map do |file|
      File.basename(file, ".tsv")
    end

    @snvids.sort_by!(&.to_i)
    puts "[INPUT: #{snvids.size} entries]"
  end

  def crawl!
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

  def parse!
    @snvids.each_with_index(1) do |snvid, idx|
      file = File.join(INP_DIR, "#{snvid}.html.gz")

      next unless atime = SeedUtil.get_mtime(file)
      next if @seed._index.ival_64(snvid) >= atime

      parser = ZxcsMeInfoParser.new(snvid, file)

      puts "\n- <http://www.zxcs.me/post/#{snvid}>".colorize.cyan
      next unless result = parser.parse!

      btitle, author = result
      puts "- <#{idx}/#{@snvids.size}}> {#{snvid}} [#{btitle}  #{author}]"

      @seed._index.set!(snvid, [atime.to_s, btitle, author])
      @seed.set_intro(snvid, parser.bintro)

      @seed.genres.set!(snvid, parser.genres)
      @seed.bcover.set!(snvid, parser.bcover)
    rescue err
      puts [snvid, err.message.colorize.red]
      gets
    end

    @seed.save!(clean: false)
  end

  def inherit!
    atime = Time.utc(2019, 1, 1).to_unix.to_s

    inputs = Hash(String, ZxcsMeJson).from_json File.read("_db/_seeds/zxcs_me/prevs.json")
    inputs.each do |snvid, input|
      next if @seed._index.get(snvid)

      puts " - <#{snvid}> [#{input.btitle} #{input.author}]"
      @seed._index.set!(snvid, [atime, input.btitle, input.author])

      @seed.set_intro(snvid, input.bintro)
      @seed.genres.set!(snvid, input.genres)
    end

    @seed.save!(clean: false)
  end
end

worker = CV::InitZxcsMe.new
worker.crawl!
worker.parse!
worker.inherit!
