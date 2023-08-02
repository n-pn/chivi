# require "./dl_host"
# require "./dl_page"

# class DlChap
#   def self.new(link : String, ttl = 10.days)
#     uri = URI.parse(link)
#     host = DlHost.load_by_name(uri.hostname.as(String)) { uri.scheme != "https" }

#     path = uri.path.as(String)
#     html = host.get_page(path, ttl: ttl)

#     new(host, html, path)
#   end

#   @doc : DlPage

#   getter title : String

#   def initialize(@host : DlHost, html : String, @path : String)
#     @doc = DlPage.new(html)
#     @title = get_title(@host.chap_name_css)
#   end

#   def get_title(chap_name_css : String)
#     elem = @doc.find!(chap_name_css)

#     if @host.hostname.ends_with?("ptwxz.com")
#       elem.children.each { |node| node.remove! if node.tag_sym == :a }
#     end

#     title = @doc.inner_text(elem, ' ')

#     case @host.hostname
#     when "www.69shu.com"
#       title.sub(/^\d+\.第/, "第")
#     else
#       title
#         .sub(/^章节目录\s*/, "")
#         .sub(/(《.+》)?正文\s*/, "")
#     end
#   end

#   getter body : Array(String) do
#     return get_hts_body if @host.hostname.ends_with?("hetushu.com")

#     purge_tags = {:script, :div, :h1, :table, :ul}
#     lines = @doc.get_lines(@host.chap_body_css, purge_tags)
#     return lines if lines.empty?

#     lines.shift if reject_first_line?(lines.first)
#     lines.pop if lines.last == "(本章完)"

#     @host.autogen.chap_body_clean.each do |regex|
#       lines.map!(&.gsub(regex, ""))
#     end

#     lines.reject(&.empty?)
#   rescue ex
#     Log.error(exception: ex) { "error extracting body" }
#     [] of String
#   end

#   private def reject_first_line?(first : String)
#     case first
#     when .starts_with?("笔趣阁"), .starts_with?("笔下文学")
#       true
#     when .starts_with?('，')
#       @host.hostname.in?("www.b5200.org", "www.biqu5200.net")
#     else
#       @title.split(' ') do |frag|
#         first = first.sub(/^#{Regex.escape(frag)}\s*/, "")
#       end

#       first !~ /\p{Han}/
#     end
#   end

#   private def get_hts_body
#     file_path = @host.cache_path(@path, "tok")

#     base64 = load_hts_encrypt_string(file_path)
#     reorder = Base64.decode_string(base64).split(/[A-Z]+%/).map(&.to_i)

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

#   private def load_hts_encrypt_string(file_path : String)
#     return File.read(file_path) if File.exists?(file_path)

#     url_path = @path.sub(/(\d+)\.html$/) { "r#{$1}.json" }
#     @host.fetch_page(url_path, @host.hts_headers(@path)) do |res|
#       res.headers["token"].tap { |x| File.write(file_path, x) }
#     end
#   end
# end
