require "./scrape_rules"
require "../../_util/hash_util"

class SC::WnchapPage
  def self.from_link(url : String, ttl : Time = Time.utc - 10.years, use_proxy : Bool = false)
    uri = URI.parse(url)
    name = uri.host.as(String).lchop("www.")

    rule = WnchapRule.load_rule(name)
    html = rule.get_html(url: url, uri: uri, ttl: ttl, use_proxy: use_proxy)

    new(html: html, rule: rule)
  end

  getter rule : WnchapRule

  def initialize(html : Sring, @rule : WnchapRule)
    @page = HtmlParser.new(html)
  end

  def get_title(query : String = @rule.title_rule)
    title = @page.text(query, joiner: '\n', remove: /^.+\n/)
    title.sub(/^\d+\.(?=第)|^章节目录|^正文\s|^《.+》正文/, "").strip
  end

  def get_cbody(query : String = @rule.cbody_rule, title = self.get_title)
    node = @page.get(query)

    node.children.each do |child|
      case child.tag_sym
      when :script, :div, :h1, :table, :ul, :a
        child.remove!
      when :p
        child.remove! if child.attributes["style"]? || child.attributes["class"]? == "readinline"
      end
    end

    paras = [] of String
    scrub = @rule.cbody_gsub.try { |gsub| Regex.new(gsub) }

    node.inner_text('\n').each_line do |line|
      scrub.try { |re| line = line.gsub(re, "") }

      line = CharUtil.trim_sanitize(line)
      next if line.empty?

      paras << line
    end

    paras.pop if paras.last? == "（本章完）"

    paras.shift if paras.first?.try(&.matches?(/^\P{Han}*#{Regex.escape(title)}\P{Han}*$/))
    paras.shift if paras.first?.in?("笔趣阁", "笔下文学")

    paras
  end

  def get_ztext
    zsize = 0
    cksum = HashUtil::BASIS_32
    ztext = String::Builder

    title = get_title(@rule.title_rule)

    ztext << title
    zsize &+= title.size
    cksum = HashUtil.fnv_1a(title, hash: cksum)

    paras = get_cbody(@rule.cbody_rule, title: title)

    paras.each do |line|
      ztext << '\n' << line
      zsize &+= line.size &+ 1
      cksum = HashUtil.fnv_1a('\n', hash: cksum)
      cksum = HashUtil.fnv_1a(line, hash: cksum)
    end

    {ztext.to_s, title, zsize, cksum}
  end
end
