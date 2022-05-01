require "tabkv"
require "lexbor"
require "../src/appcv/shared/sname_map"

DIR = ".cache/index"
Dir.mkdir_p(DIR)

def fresh?(file : String, ttl = 1.days) : Bool
  return false unless mtime >= Time.utc - ttl
end

def get_page(file : String, link : String, ttl = 1.days)
  unless File.info?(file).try(&.modification_time.>= Time.utc - ttl)
    loop do
      puts "- Fetching #{file}".colorize.cyan
      `curl -L -k -s -f -m 30 '#{link}' -o #{file}`
      break if $?.success?
    end
  end

  File.read(file)
end

# ameba:disable Metrics/CyclomaticComplexity
private def index_link(sname : String) : String
  case sname
  when "yousuu"   then "https://www.yousuu.com/newbooks"
  when "69shu"    then "https://www.69shu.com/"
  when "hetushu"  then "https://www.hetushu.com/book/index.php"
  when "rengshu"  then "http://www.rengshu.com/"
  when "xbiquge"  then "https://www.xbiquge.so/"
  when "biqugee"  then "https://www.biqugee.com/"
  when "biquyue"  then "https://www.biquyue.com/"
  when "5200"     then "https://www.5200.tv/"
  when "duokan8"  then "http://www.duokanba.com/"
  when "sdyfcm"   then "https://www.sdyfcm.com/"
  when "biqu5200" then "http://www.biqu5200.net/"
  when "bxwxorg"  then "https://www.bxwxorg.com/"
  when "shubaow"  then "https://www.shubaow.net/"
  when "paoshu8"  then "http://www.paoshu8.com/"
  else                 raise "Unsupported source name!"
  end
end

def extract_upper(sname : String) : String
  html = get_page("#{DIR}/#{sname}.html", index_link(sname))
  page = Lexbor::Parser.new(html)

  case sname
  when "yousuu"
    get_upper(page, ".book-info > .book-name")
  when "duokan8"
    get_upper(page, ".recommend-list ul:not([class]) a:first-of-type").split("_").last
  when "69shu"
    get_upper(page, ".ranking:nth-child(2) a:first-of-type", ".htm")
  when "hetushu"
    get_upper(page, "#list a:first-of-type", "/index.html")
  when "sdyfcm"
    get_upper(page, "#newscontent_n .s2 > a")
  when "5200"
    get_upper(page, ".up > .r .s2 > a").split("_").last
  when "biqu5200", "paoshu8", "shubaow", "biquyue"
    get_upper(page, "#newscontent > .r .s2 > a").split("_").last
  else
    get_upper(page, "#newscontent > .r .s2 > a")
  end
end

def get_upper(page : Lexbor::Parser, query : String, clean = "")
  node = page.css(query).first
  File.basename(node.attributes["href"].sub(clean, ""))
end

output = Tabkv(String).new("var/_common/upper.tsv")
snames = ARGV.empty? ? ["yousuu"].concat(CV::SnameMap.alive_snames) : ARGV

snames.each do |sname|
  output.upsert(sname, extract_upper(sname))
rescue err
  puts sname, err.inspect_with_backtrace
end

output.save!(clean: true)
