require "cmark"

class CV::PostUtil
  OPTS = Cmark::Option.flags(Hardbreaks, ValidateUTF8, FullInfoString)

  def self.parse_md(input : String)
    Cmark.gfm_to_html(input, OPTS)
  end

  def self.html_to_text(input : String)
  end
end
