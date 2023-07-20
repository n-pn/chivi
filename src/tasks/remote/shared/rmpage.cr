require "lexbor"

class Rmpage
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

  @[AlwaysInline]
  def get!(query : String, attr : String = "") : String
    get(query, attr) || raise "invalid query: #{query}"
  end

  def get_all(query : String, attr : String = "") : Array(String)
    @doc.css(query).map { |x| get_text(x, attr) }
  end

  def get_lines(query : String, purges : Enumerable(Symbol)) : Array(String)
    return [] of String unless node = find(query)
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

  @[AlwaysInline]
  def inner_text(node : Lexbor::Node, sep = '\n')
    clean_text(node.inner_text(sep))
  end

  private def get_text(node : Lexbor::Node, attr : String)
    text = attr.empty? ? node.inner_text(' ') : node.attributes[attr]? || ""
    clean_text(text)
  end

  @[AlwaysInline]
  private def clean_text(text : String)
    text.gsub(/\p{Z}/, ' ').strip
  end
end
