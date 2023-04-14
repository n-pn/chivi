require "cmark"
require "lexbor"

class PostUtil
  OPTS = Cmark::Option.flags(Hardbreaks, ValidateUTF8, FullInfoString)

  def self.md_to_html(input : String) : String
    Cmark.gfm_to_html(input, OPTS)
  end

  def self.render_md(input : String)
    vhtml = md_to_html(input)
    users = [] of String

    vhtml = vhtml.gsub(/@\[(.+?)\]/) do |uname|
      users << uname
      "<cv-user>@[#{uname}]</cv-user>"
    end

    {vhtml, users}
  end

  def self.html_to_text(input : String)
    input = "<html><body>#{input}</body></html>"
    Lexbor::Parser.new(input).body.try(&.inner_text) || raise "invalid!"
  end
end
