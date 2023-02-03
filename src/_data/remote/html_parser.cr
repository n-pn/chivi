# require "lexbor"
# require "../../_util/text_util"

# class CV::HtmlParser
#   def initialize(html : String)
#     @doc = Lexbor::Parser.new(html)
#   end

#   # forward_missing_to @doc
#   delegate css, to: @doc

#   # find the first node matching the query, return nil otherwise
#   def find(query : String)
#     @doc.css(query, &.first?)
#   end

#   def find_list(query : String)
#     @doc.css(query, &.to_a)
#   end

#   # reading attribute data of a node
#   def attr(query : String, name : String)
#     find(query).try(&.attributes[name]?) || yield
#   end

#   def attr(node : Lexbor::Node, name : String)
#     node.attributes[name]? || ""
#   end

#   def attr(query : String, name : String)
#     attr(query, name) { "" }
#   end

#   # return inner text
#   def text(query : String, sep = "  ") : String
#     return yield unless node = find(query)
#     TextUtil.fix_spaces(node.inner_text(sep)).strip
#   end

#   def text(query : String, sep = "  ") : String
#     text(query, sep) { "" }
#   end

#   def text(node : Lexbor::Node, sep = "  ") : String
#     node.inner_text(sep)
#   end

#   # return multi text entries for each nodes
#   def text_list(query : String) : Array(String)
#     @doc.css(query) { |x| x.map(&.inner_text) }
#   end

#   # split text string to multi lines
#   def text_para(query : String) : Array(String)
#     TextUtil.split_html(text(query, "\n"))
#   end

#   # extract open graph metadata
#   def meta(query : String)
#     attr("meta[property=\"#{query}\"]", "content")
#   end

#   # split meta content to multi lines
#   def meta_para(query : String) : Array(String)
#     TextUtil.split_html(meta(query))
#   end

#   def inner_text(node : Lexbor::Node)
#     node.inner_text.sub(/^.+：/, "").strip
#   end

#   def clean_node(node : Lexbor::Node, *tags : Symbol)
#     node.children.each do |tag|
#       tag.remove! if tags.includes?(tag.tag_sym)
#     end
#   end
# end
