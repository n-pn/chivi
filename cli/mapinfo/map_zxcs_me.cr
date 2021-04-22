require "file_utils"
require "compress/gzip"
require "json"

require "myhtml"
require "../../src/utils/http_utils"
require "./_bookgen"

class CV::MapZxcsMe
  INP_DIR = "_db/.cache/zxcs_me/infos"
  OUT_DIR = "_db/_seeds/zxcs_me"
  IDX_DIR = "_db/ch_infos/origs/zxcs_me"

  ::FileUtils.mkdir_p(INP_DIR)
  ::FileUtils.mkdir_p(OUT_DIR)

  getter snvids : Array(String)

  def initialize
    @meta = Bookgen::Seed.new("zxcs_me")

    @snvids = Dir.glob("#{IDX_DIR}/*.tsv").map do |file|
      File.basename(file, ".tsv")
    end

    @snvids.sort_by!(&.to_i)
    puts "[INPUT: #{snvids.size} entries]"
  end

  def prep!
    @snvids.each_with_index(1) do |snvid, idx|
      file = File.join(INP_DIR, "#{snvid}.html.gz")
      next if File.exists?(file)

      link = "http://www.zxcs.me/post/#{snvid}"

      File.open(file, "w") do |io|
        html = HttpUtils.get_html(link, label: "#{idx}/#{@snvids.size}")
        Compress::Gzip::Writer.open(io, &.print(html))
      end

      sleep Random.rand(500).milliseconds
    rescue err
      puts err.colorize.red
    end
  end

  def init!
    @snvids.each_with_index(1) do |snvid, idx|
      file = File.join(INP_DIR, "#{snvid}.html.gz")

      next unless atime = Bookgen.get_mtime(file)
      next if @meta._index.ival_64(snvid) >= atime

      parser = Parser.new(snvid, file)

      puts "\n- <http://www.zxcs.me/post/#{snvid}>".colorize.cyan
      next unless result = parser.parse!

      btitle, author = result
      puts "- <#{idx}/#{@snvids.size}}> {#{snvid}} [#{btitle}  #{author}]"

      @meta._index.set!(snvid, [atime.to_s, btitle, author])
      @meta.genres.set!(snvid, parser.genres)
      @meta.bcover.set!(snvid, parser.bcover)
      @meta.set_intro(snvid, parser.bintro)
    rescue err
      puts [snvid, err.message.colorize.red]
      gets
    end

    @meta.save!(clean: false)
  end

  class Parser
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

  class Prev
    include JSON::Serializable

    property btitle : String
    property author : String
    property bintro : Array(String)
    property genres : Array(String)
  end

  def import_prev!
    atime = Time.utc(2019, 1, 1).to_unix.to_s

    inputs = Hash(String, Prev).from_json File.read("_db/_seeds/zxcs_me/prevs.json")
    inputs.each do |snvid, input|
      next if @meta._index.get(snvid)

      puts " - <#{snvid}> [#{input.btitle} #{input.author}]"
      @meta._index.set!(snvid, [atime, input.btitle, input.author])

      @meta.set_intro(snvid, input.bintro)
      @meta.genres.set!(snvid, input.genres)
    end

    @meta.save!(clean: false)
  end

  def seed!
    @snvids.each_with_index(1) do |snvid, idx|
      bhash, btitle, author = @meta.upsert!(snvid, fixed: false)

      if NvOrders.get_voters(bhash) == 0
        voters, rating = Bookgen.get_scores(btitle, author)
        NvOrders.set_scores!(bhash, voters, rating)
      end

      puts "- <#{idx}/#{@snvids.size}> [#{bhash}] saved!".colorize.yellow

      mtime = @meta._index.ival_64(snvid)
      total = File.read_lines("#{IDX_DIR}/#{snvid}.tsv").size
      NvInfo.new(bhash).set_chseed("zxcs_me", snvid, mtime, total)

      NvInfo.save!(clean: false)
    end

    NvInfo.save!(clean: false)
  end
end

worker = CV::MapZxcsMe.new
worker.prep!
worker.init!
worker.import_prev!
worker.seed!
