require "html"

module SeedUtils
  extend self

  WHITESPACES = "\u00A0\u2002\u2003\u2004\u2007\u2008\u205F\u3000"

  def clean_split(input : String)
    input = HTML.unescape(input)

    input
      .tr(WHITESPACES, " ")
      .gsub(/<br\s*\/?>|\s{2,}/i, "\n")
      .split(/\n+/).map(&.strip).reject(&.empty?)
  end
end
