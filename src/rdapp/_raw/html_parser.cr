require "lexbor"
require "../../_util/char_util"

class SC::HtmlParser
  getter doc : Lexbor::Parser
  forward_missing_to @doc

  def initialize(html : String)
    @doc = Lexbor::Parser.new(html)
  end

  @[AlwaysInline]
  def purge!(node = @doc, *tags : Symbol)
    node.children.each { |x| x.remove! if tags.includes?(x.tag_sym) }
  end

  @[AlwaysInline]
  def get(query : String)
    @doc.css(query, &.first?)
  end

  @[AlwaysInline]
  def get!(query : String)
    @doc.css(query, &.first)
  end

  @[AlwaysInline]
  def attr(query : String, attr : String, clean : Bool = true)
    data = self.get!(query).attributes[attr]
    clean ? clean_text(data) : data
  end

  @[AlwaysInline]
  def text(query : String, joiner : String | Char = '\t', clean : Bool = true, remove : Nil = nil)
    text = self.get!(query).inner_text(joiner)
    clean ? clean_text(text) : text
  end

  @[AlwaysInline]
  def text(query : String, joiner : String | Char = '\t', clean : Bool = true, remove : Regex = /^\p{Z}|\p{Z}$/)
    text = self.get!(query).inner_text(joiner)
    text = clean_text(text) if clean
    text.gsub(remove, "")
  end

  def text_list(query : String, joiner : String | Char = '\t', clean : Bool = true, remove : Regex | Nil = nil) : Array(String)
    @doc.css(query).to_a.compact_map do |node|
      text = node.inner_text(joiner)
      text = clean_text(text) if clean
      text = text.gsub(remove, "") if remove
      text unless text.blank?
    end
  end

  @[AlwaysInline]
  private def clean_text(text : String)
    CharUtil.fast_sanitize(text).strip
  end

  @[AlwaysInline]
  private def clean_text(list : Array(String))
    list.map! { |text| clean_text(text) }
  end
end
