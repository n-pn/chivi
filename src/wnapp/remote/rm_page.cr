require "log"
require "colorize"
# require "http/client"

require "lexbor"

require "../../_util/http_util"
require "../../_util/zstd_util"
require "../../_util/time_util"

class WN::RmPage
  getter doc : Lexbor::Parser
  delegate css, to: @doc

  # forward_missing_to @doc

  def initialize(html : String)
    @doc = Lexbor::Parser.new(html)
  end

  def purge_tags!(node : Lexbor::Node, *tags : Symbol)
    node.children.each { |x| x.remove! if tags.includes?(x.tag_sym) }
  end

  @[AlwaysInline]
  def find!(query : String)
    @doc.css(query, &.first)
  end

  @[AlwaysInline]
  def find(query : String)
    @doc.css(query, &.first?)
  end

  @[AlwaysInline]
  def get(query : String, attr : String = "") : String?
    return unless node = find(query)
    get_text(node, attr)
  end

  def get_all(query : String, attr : String = "") : Array(String)
    @doc.css(query).map { |x| get_text(x, attr) }
  end

  def get_lines(query : String, purges : Enumerable(Symbol)) : Array(String)
    node = find!(query)
    node.children.each { |x| x.remove! if purges.includes?(x.tag_sym) }

    get_lines(node)
  end

  @[AlwaysInline]
  def get_lines(query : String) : Array(String)
    get_lines(@doc.css(query))
  end

  def get_lines(node : Lexbor::Node) : Array(String)
    text = node.inner_text('\n')

    text.each_line.compact_map do |line|
      line = clean_text(line)
      line unless line.blank?
    end.to_a
  end

  private def get_text(node : Lexbor::Node, attr : String)
    text = attr.empty? ? node.inner_text(' ') : node.attributes[attr]? || ""
    clean_text(text)
  end

  @[AlwaysInline]
  private def clean_text(text : String)
    text.gsub(/\p{Z}/, ' ').strip
  end

  # class methods

  CACHE_DIR = "var/.html"

  def self.cache_file(link : String)
    parts = link.split('/', 4)

    dir = "#{CACHE_DIR}/#{parts[2]}" # host name
    Dir.mkdir_p(dir)

    path = parts[3].gsub(/\W/, '_') # path name
    "#{dir}/#{path}.htm.zst"
  end

  def self.cached?(file : String, ttl : Time::Span | Time::MonthSpan)
    return false unless info = File.info?(file)
    info.modification_time > Time.utc - ttl
  end

  def self.get_host(href : String)
    String.build do |io|
      count = 0
      href.each_char do |char|
        if char == '/'
          break if count == 2
          count += 1
        end

        io << char
      end
    end
  end

  def self.load_html(link : String, ttl : Time::Span | Time::MonthSpan, encoding : String)
    file = cache_file(link)

    if cached?(file, ttl: ttl)
      html = ZstdUtil.read_file(file)
    else
      html = HttpUtil.fetch(link, encoding: encoding)
      ZstdUtil.save_ctx(html, file)
    end

    html
  end
end
