require "../kernel/label_map"
require "../kernel/value_set"

module SourceUtil
  extend self

  FIX_TITLES  = LabelMap.load("fix_zh_titles")
  FIX_AUTHORS = LabelMap.load("fix_zh_authors")

  def fix_title(title : String)
    title = remove_trashes(replace_spaces(title))
    FIX_TITLES.fetch(title, title)
  end

  def fix_author(author : String, title : String)
    author = remove_trashes(replace_spaces(author).sub(/\s*\.QD$/, ""))
    return author unless match = FIX_AUTHORS.fetch(author)

    splits = match.split("¦")
    match_author = splits[0]

    return match_author unless match_title = splits[1]?
    match_title == title ? match_author : author
  end

  def replace_spaces(input : String)
    input.gsub(/\p{Z}/, " ").strip
  end

  def remove_trashes(input : String)
    input.sub(/\s*\(.+\)$/, "")
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
