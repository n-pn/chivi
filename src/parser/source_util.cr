require "../lookup/label_map"
require "../lookup/value_set"

module SourceUtil
  extend self

  TITLES  = LabelMap.load!("override/title_zh")
  AUTHORS = LabelMap.load!("override/author_zh")

  def fix_title(title : String)
    title = remove_trashes(replace_spaces(title))
    TITLES.fetch(title, title)
  end

  def fix_author(author : String, title : String)
    author = remove_trashes(replace_spaces(author).sub(/\s*\.QD$/, ""))
    return author unless match = AUTHORS.fetch(author)

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

  BLACKLIST = ValueSet.load!("title-blacklist")

  def blacklist?(title : String)
    BLACKLIST.includes?(title)
  end
end
