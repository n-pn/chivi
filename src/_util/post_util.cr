require "cmark"
require "myhtml"

class CV::PostUtil
  OPTS = Cmark::Option.flags(Hardbreaks, ValidateUTF8, FullInfoString)

  def self.md_to_html(input : String)
    Cmark.gfm_to_html(input, OPTS)
  end

  def self.html_to_text(input : String)
    input = "<html><body>#{input}</body></html>"
    Myhtml::Parser.new(input).body.not_nil!.inner_text('\n')
  end
end
