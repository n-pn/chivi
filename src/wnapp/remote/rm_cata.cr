# # require "./html_parser"
# require "yaml"
# require "json"

# require "./rm_page"
# require "../data/wn_chap"

# require "../../_util/text_util"

# class WN::RmCata
#   struct Conf
#     include YAML::Serializable

#     getter encoding = "GBK"
#     getter sites = [] of String

#     getter parse = "chdiv"
#     getter query = "#list > dl"

#     getter s_cid = "(\\d+)\\.html?$"

#     getter latest_chap = %{meta[property="og:novel:latest_chapter_url"]@content}
#     getter update_time = %{meta[property="og:novel:update_time"]@content}

#     @[YAML::Field(ignore: true)]
#     @s_cid_re : Regex = /(\d+)\.html?$/

#     @[YAML::Field(ignore: true)]
#     @chap_css : String = ""
#     @[YAML::Field(ignore: true)]
#     @chap_key : String = ""

#     @[YAML::Field(ignore: true)]
#     @time_css : String = ""
#     @[YAML::Field(ignore: true)]
#     @time_key : String = ""

#     def after_initialize
#       @s_cid_re = Regex.new(@s_cid)

#       @chap_css, @chap_key = @latest_chap.split('@')
#       @time_css, @time_key = @update_time.split('@')
#     end

#     def get_s_cid(href : String)
#       match = @s_cid_re.match(href)
#       match ? match.[1].to_i : raise "link not match to any parser"
#     end

#     def get_latest_chap(page : RmPage)
#       href = page.get(@chap_css, @chap_key)

#       href ? get_s_cid(href) : 0
#     end

#     def get_update_time(page : RmPage)
#       time = page.get(@time_css, @time_key)
#       Log.info { time.colorize.blue }
#       time ? TimeUtil.parse_time(time).to_unix : 0_i64
#     end

#     ###

#     class_getter confs = begin
#       yaml = File.read("var/_conf/rm_cata.yml")
#       Hash(String, Conf).from_yaml(yaml)
#     end

#     def self.load(sname : String)
#       @@confs[sname]? || raise "no matching config"
#     end

#     def self.find(link : String)
#       @@confs.each_value.find do |conf|
#         conf.sites.any? { |x| link.includes?(x) }
#       end
#     end
#   end

#   def self.new(link : String, ttl : Time::MonthSpan | Time::Span = 1.years)
#     conf = Conf.find(link) || Conf.load("biquge")

#     html = RmPage.load_html(link, ttl: ttl, encoding: conf.encoding)
#     new(html, conf, link)
#   end

#   def initialize(html : String, @conf : Conf, link : String)
#     @doc = RmPage.new(html)

#     @root = link.ends_with?('/') ? link : File.dirname(link) + "/"
#     @host = RmPage.get_host(link)
#   end

#   getter last_s_cid : Int32 { @conf.get_latest_chap(@doc) }
#   getter last_mtime : Int64 { @conf.get_update_time(@doc) }

#   def changed?(prev_s_cid : Int32, prev_mtime : Int64)
#     return true if last_s_cid != prev_s_cid
#     last_mtime > 0 && last_mtime != prev_mtime
#   end

#   getter chaps = [] of WnChap

#   def parse! : Array(WnChap)
#     case @conf.parse
#     when "plain"    then extract_plain(@conf.query)
#     when "chdiv"    then extract_chdiv(@conf.query)
#     when "ymxwx"    then extract_ymxwx(@conf.query)
#     when "wenku"    then extract_wenku(@conf.query)
#     when "uukanshu" then extract_uukanshu(@conf.query)
#     else                 raise "unsupported #{@conf.parse} parser type"
#     end

#     @chaps
#   end

#   private def clean_chdiv(chdiv : String)
#     chdiv.gsub(/《.*》/, "").gsub(/\n|\t|\s{3,}/, "  ").strip
#   end

#   private def gen_path(href : String)
#     # TODO: config this in yml
#     return href if href.starts_with?("http")
#     return "http:#{href}" if @conf.parse == "ymxwx"

#     href[0] == '/' ? "#{@host}#{href}" : "#{@root}#{href}"
#   end

#   private def add_chap(node : Lexbor::Node?, chdiv = "")
#     return unless node && (href = node.attributes["href"]?)

#     ch_no = @chaps.size &+ 1
#     s_cid = @conf.get_s_cid(href)

#     title = node.inner_text("  ")
#     return if title.empty?

#     title, chdiv = TextUtil.format_title(title, chdiv)

#     @chaps << WnChap.new(ch_no, s_cid, title, chdiv, gen_path(href))
#   rescue ex
#     Log.error(exception: ex) { ex.message.colorize.red }
#   end

#   private def extract_chdiv(query : String)
#     return unless body = @doc.find(query)
#     chdiv = ""

#     body.children.each do |node|
#       case node.tag_sym
#       when :dt
#         inner = node.css("b", &.first?) || node
#         chdiv = clean_chdiv(inner.inner_text)
#         add_chap(node.css("a", &.first?), chdiv)
#       when :dd
#         next if chdiv.includes?("最新章节")
#         add_chap(node.css("a", &.first?), chdiv)
#       end
#     end
#   end

#   private def extract_ymxwx(query : String)
#     return unless body = @doc.find(query)
#     chdiv = ""

#     body.children.each do |node|
#       next unless node.tag_sym == :li

#       case node.attributes["class"]?
#       when "col1 volumn"
#         chdiv = clean_chdiv(node.inner_text)
#       when "col3"
#         next if chdiv.includes?("最新九章")
#         add_chap(node.css("a", &.first?), chdiv)
#       end
#     end
#   end

#   private def extract_wenku(query : String)
#     return unless body = @doc.find(query)
#     chdiv = ""

#     body.css("td").each do |node|
#       case node.attributes["class"]?
#       when "vcss"
#         chdiv = clean_chdiv(node.inner_text)
#       when "ccss"
#         add_chap(node.css("a", &.first?), chdiv)
#       end
#     end
#   end

#   private def extract_plain(query : String)
#     @doc.css(query).each { |link_node| add_chap(link_node) }
#   end

#   private def extract_uukanshu(query : String)
#     return unless body = @doc.find(query)
#     chdiv = ""

#     body.children.to_a.reverse_each do |node|
#       if node.attributes["class"]? == "volume"
#         chdiv = node.inner_text.strip
#       else
#         add_chap(node.css("a").first?, chdiv)
#       end
#     end
#   end
# end
