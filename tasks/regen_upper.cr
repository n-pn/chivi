require "tabkv"
require "lexbor"
require "../src/_data/shared/sname_map"

DIR = "var/books/.html"
Dir.mkdir_p(DIR)

def fresh?(file : String, ttl = 1.days) : Bool
  return false unless info = File.info?(file)
  info.modification_time + ttl >= Time.utc
end

def get_page(file : String, link : String, ttl = 1.days)
  unless fresh?(file, ttl)
    try = 0

    loop do
      try += 1
      puts "- Fetching #{link} (try: #{try})".colorize.cyan
      `curl -L -k -s -f -m 30 '#{link}' -o #{file}`
      break if $?.success?
    end
  end

  File.read(file)
end

# ameba:disable Metrics/CyclomaticComplexity
private def index_link(sname : String) : String
  case sname
  when "xswang"   then "https://www.xswang.com/"
  when "xbiquge"  then "https://www.xbiquge.bz/"
  when "biquyue"  then "https://www.biquyue.com/"
  when "5200"     then "https://www.5200.tv/"
  when "duokan8"  then "http://www.duokanba.com/"
  when "biqu5200" then "http://www.biqu5200.net/"
  when "paoshu8"  then "http://www.paoshu8.com/"
  else                 raise "Unsupported source name!"
  end
end

def extract_upper(sname : String) : String
  html = get_page("#{DIR}/#{sname}.html", index_link(sname))
  page = Lexbor::Parser.new(html)

  case sname
  when "yousuu"
    parser_elem(page, ".book-info > .book-name")
  when "duokan8"
    parser_elem(page, ".recommend-list ul:not([class]) a:first-of-type").split("_").last
  when "69shu"
    parser_elem(page, ".mybox > .ranking .active > a", ".htm")
  when "hetushu"
    parser_elem(page, "#list a:first-of-type", "/index.html")
  when "biqu5200", "paoshu8", "shubaow", "biquyue"
    parser_elem(page, "#newscontent > .r .s2 > a").split("_").last
  when "sdyfcm"
    parser_elem(page, "#newscontent_n .s2 > a")
  when "xswang"
    parser_elem(page, "#newscontent .s2 > a")
  when "5200"
    parser_elem(page, ".up > .r .s2 > a").split("_").last
  else
    parser_elem(page, "#newscontent > .r .s2 > a")
  end
end

def parser_elem(page : Lexbor::Parser, query : String, clean = "")
  node = page.css(query).first
  File.basename(node.attributes["href"].sub(clean, ""))
end

output = Tabkv(String).new("var/books/upper.tsv")
snames = ARGV.reject(&.starts_with?('-'))

snames.each do |sname|
  upper = extract_upper(sname)
  puts "#{sname} => #{upper}"
  output.upsert(sname, upper)
rescue err
  puts sname, err.inspect_with_backtrace
end

output.save!(clean: true)
