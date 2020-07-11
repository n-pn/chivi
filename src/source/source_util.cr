require "../kernel/label_map"
require "../kernel/value_set"

module SourceUtil
  extend self

  FIX_TITLES  = LabelMap.load("fix_zh_titles")
  FIX_AUTHORS = LabelMap.load("fix_zh_authors")

  def fix_title(title : String)
    title = title.sub(/\(.+\)$/, "").strip
    FIX_TITLES.fetch(title, title)
  end

  def fix_author(title : String, author : String)
    author = author.sub(/\(.+\)|.QD$/, "").strip
    FIX_AUTHORS.fetch(title, author)
  end

  def fix_genre(genre : String)
    return genre if genre.empty? || genre == "轻小说"
    genre.sub(/小说$/, "")
  end

  SKIP_TITLES = ValueSet.load("skip_titles")

  def blacklist?(title : String)
    SKIP_TITLES.includes?(title)
  end
end
