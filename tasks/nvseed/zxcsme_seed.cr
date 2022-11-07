require "compress/gzip"
require "json"
require "lexbor"

require "../../src/_util/http_util"
require "../../src/_util/file_util"
require "../shared/nvseed_data"

class CV::ZxcsmeParser
  def initialize(@snvid : String, gz_file : String)
    html = File.open(gz_file) do |io|
      Compress::Gzip::Reader.open(io, &.gets_to_end)
    end

    @doc = Lexbor::Parser.new(html)
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

  getter status_str : String { author.ends_with?("【断更】") ? "2" : "1" }
  getter status_int : Int32 { status_str.to_i }

  property update_str = ""
  property update_int = 0_i64
end

class CV::ZxcsmeJson
  include JSON::Serializable

  property btitle : String
  property author : String

  property genres : Array(String)
  property bintro : Array(String)
  property bcover : String = ""

  getter status_str : String { author.ends_with?("【断更】") ? "2" : "1" }
  getter status_int : Int32 { status_str.to_i }

  property update_str = ""
  property update_int = 0_i64
end

module CV::SeedZxcsme
  extend self

  INP_DIR = "_db/.cache/zxcs_me/infos"
  TXT_DIR = "var/chaps/texts/zxcs_me"

  OUT_DIR = "var/zhinfos/zxcs_me"
  MFTIMES = Tabkv(Int64).new("#{OUT_DIR}/utimes.tsv")

  PREVS = Hash(String, ZxcsmeJson).from_json(File.read("#{OUT_DIR}/prevs.json"))
  STIME = Time.utc(2019, 1, 1).to_unix

  CACHE = {} of Int32 => ChrootData

  def load_seed(group : Int32)
    CACHE[group] ||= ChrootData.new("zxcs_me", "#{OUT_DIR}/#{group}")
  end

  def init!(redo = false)
    input = Dir.glob("#{TXT_DIR}/_/*.tsv").map { |x| File.basename(x, ".tsv") }
    puts "[INPUT: #{input.size} entries]"

    input.sort_by!(&.to_i).each_with_index(1) do |snvid, idx|
      link = "http://www.zxcs.me/post/#{snvid}"
      puts "\n- <#{link}>".colorize.cyan

      file = File.join(INP_DIR, "#{snvid}.html.gz")
      unless File.exists?(file)
        HttpUtil.load_html(link, file, lbl: "#{idx}/#{input.size}")
      end

      if stime = FileUtil.mtime(file).try(&.to_unix)
        entry = ZxcsmeParser.new(snvid, file)
      else
        next unless entry = PREVS[snvid]?
        stime = STIME
      end

      output = load_seed(snvid.to_i // 1000)
      if bindex = output._index[snvid]?
        next unless redo || bindex.stime < stime
      end

      entry.update_int = MFTIMES[snvid]? || 0_i64
      output.add!(entry, snvid, stime: stime)
    rescue err
      puts err.colorize.red
    end

    CACHE.each_value(&.save!(clean: true))
  end

  # def read_chsize(snvid : String) : Array(String)
  #   files = Dir.glob("#{TXT_DIR}/#{snvid}/*.tsv")
  #   return ["0", ""] if files.empty?

  #   flast = files.sort_by { |x| File.basename(x, ".tsv").to_i }.last

  #   lines = File.read_lines(flast).reject(&.blank?)
  #   last_chap = lines[-1].split('\t', 2)[0]

  #   [last_chap, last_chap]
  # end

  # def fix_authors!
  #   @seed.each_index do |rtitle, author|
  #     next if author.ends_with?("【断更】") # resolved
  #     next unless author =~ /[\(\[（【]/

  #     if fix_author = BookUtil.zh_authors.fval_alt("#{author}  #{rtitle}", author)
  #       puts "#{author} => #{fix_author}".colorize.green
  #       next
  #     end

  #     puts [rtitle, author].join('\t').colorize.red
  #   end
  # end

  # def fix_btitles!
  #   @seed.each_index do |rtitle, author|
  #     next unless rtitle =~ /[\(\[（【]/
  #     author = BookUtil.fix_name(:author, "#{author}  #{rtitle}", author)

  #     if ztitle = BookUtil.zh_btitles.fval_alt("#{rtitle}  #{author}", rtitle)
  #       puts "#{rtitle} => #{ztitle}".colorize.green
  #     else
  #       fix_btitle!(rtitle, author)
  #     end
  #   end
  # end

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

  private def gen_ys_title_search(title : String)
    "https://www.yousuu.com/search/?search_type=title&search_value=#{title}"
  end

  def seed!
    puts "TODO!"
  end

  def run!(argv = ARGV)
    init! if argv.includes?("-i")
    seed!
  end
end

CV::SeedZxcsme.run!
