# require "yaml"
# require "http/client"

# require "./rm_page"

# class WN::RmText
#   struct Conf
#     include YAML::Serializable

#     getter encoding = "GBK"
#     getter sites = [] of String

#     getter bname = ""
#     getter title = "h1"

#     getter body = "#content"
#     getter clean = [] of String

#     getter cookie = ""
#     getter unique = ""

#     ###

#     class_getter confs = begin
#       yaml = File.read("var/_conf/rm_chap.yml")
#       Hash(String, Conf).from_yaml(yaml)
#     end

#     def self.load(sname : String)
#       @@confs[sname]? || Conf.load("biquge")
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

#   @doc : RmPage
#   getter title : String

#   def initialize(html : String, @conf : Conf, @link : String)
#     @doc = RmPage.new(html)

#     @title = extract_title(@conf.title)
#     # @host = RmPage.get_host(link)
#   end

#   getter bname : String { @conf.bname.empty? ? "" : @doc.get(@conf.bname) || "" }

#   def extract_title(css_query : String)
#     elem = @doc.find!(css_query)
#     elem.children.each { |node| node.remove! if node.tag_sym == :a }

#     title = @doc.inner_text(elem, ' ')
#     title.sub(/^章节目录\s*/, "").sub(/(《.+》)?正文\s*/, "")
#   end

#   getter body : Array(String) do
#     return get_hetu_body if @conf.unique == "hetu"

#     purge_tags = {:script, :div, :h1, :table, :ul}
#     lines = @doc.get_lines(@conf.body, purge_tags)
#     return lines if lines.empty?

#     lines.shift if reject_first_line?(lines.first)
#     lines.pop if lines.last == "(本章完)"

#     lines
#   rescue ex
#     Log.error(exception: ex) { "error extracting body" }
#     [] of String
#   end

#   def reject_first_line?(first : String)
#     first =~ /^笔趣阁|笔下文学|，#{Regex.escape(bname)}/ || first.sub(self.title, "") !~ /\p{Han}/
#   end

#   private def get_hetu_body
#     file_path = RmPage.cache_file(@link).sub(".htm.zst", ".tok")
#     reorder = get_hetu_line_order(file_path)

#     res = Array(String).new(reorder.size, "")
#     jmp = 0

#     nodes = @doc.css("#content > div:not([class])")

#     nodes.each_with_index do |node, idx|
#       ord = reorder[idx]? || 0

#       if ord < 5
#         jmp += 1
#       else
#         ord -= jmp
#       end

#       res[ord] = node.inner_text(deep: false).strip
#     end

#     res
#   end

#   private def get_hetu_line_order(file : String)
#     base64 = load_encrypt_string(file)
#     Base64.decode_string(base64).split(/[A-Z]+%/).map(&.to_i)
#   end

#   private def load_encrypt_string(file : String)
#     return File.read(file) if File.exists?(file)

#     headers = HTTP::Headers{
#       "Referer"          => @link,
#       "Content-Type"     => "application/x-www-form-urlencoded",
#       "X-Requested-With" => "XMLHttpRequest",
#       "Cookie"           => @conf.cookie,
#     }

#     json_link = @link.sub(/(\d+).html$/) { "r#{$1}.json" }

#     HTTP::Client.get(json_link, headers: headers) do |res|
#       raise "Can't download encrypt data" unless res.success?
#       res.headers["token"].tap { |x| File.write(file, x) }
#     end
#   end
# end
