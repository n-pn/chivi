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
  def find!(selector : String)
    @doc.css(selector, &.first)
  end

  @[AlwaysInline]
  def find(selector : String)
    @doc.css(selector, &.first?)
  end

  @[AlwaysInline]
  def inner_text(node : Lexbor::Node, sep = '\n')
    clean_text(node.inner_text(sep))
  end

  private def extract_text(node : Lexbor::Node, extract_type : String)
    case extract_type
    when "", "text" then node.inner_text(' ')
    when "para"     then node.inner_text('\n')
    else                 node.attributes[extract_type]? || ""
    end
  end

  @[AlwaysInline]
  private def clean_text(text : String)
    text.gsub(/\p{Z}/, ' ').strip
  end

  @[AlwaysInline]
  private def clean_text(text : Array(String))
    text.map! { |line| clean_text(line) }
  end

  @[AlwaysInline]
  def get(selector : String, extract_type : String = "") : String?
    find(selector).try do |node|
      text = extract_text(node, extract_type)
      clean_text(text)
    end
  end

  @[AlwaysInline]
  def get(extractor : Tuple(String, String)) : String?
    selector, extract_type = extractor
    return get(selector, extract_type) unless extract_type.ends_with?("_list")

    extract_type = extract_type.sub("_list", "")
    text_joiner = extract_type == "para" ? '\n' : '\t'

    @doc.css(selector).map { |x| extract_text(x, extract_type) }.join(text_joiner)
  end

  @[AlwaysInline]
  def get!(query : String, attr : String = "") : String
    get(query, attr) || raise "invalid query: #{query}"
  end

  @[AlwaysInline]
  def get!(extractor : Tuple(String, String)) : String?
    get(extractor) || raise "invalid extractor #{extractor}"
  end

  def get_all(query : String, attr : String = "") : Array(String)
    @doc.css(query).map { |x| extract_text(x, attr) }
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
end
