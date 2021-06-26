require "../../cutil/text_utils"
require "../../tsvfs/value_map"
require "../../libcv/cvmtl"

module CV::BookUtils
  extend self

  def hanviet(input : String, caps : Bool = true)
    return input unless input =~ /\p{Han}/ # return if no hanzi found

    output = Cvmtl.hanviet.translit(input, false).to_s
    caps ? TextUtils.titleize(output) : output
  end

  DIR = "db/nv_fixes"

  class_getter fix_author : ValueMap { ValueMap.new("#{DIR}/authors_zh.tsv") }

  def fix_author(author : String, ztitle : String)
    if author = author_map.fval("#{author}  #{ztitle}") || author_map.fval(author)
      return author
    end

    author = author.sub(/(　ˇ第.+章ˇ )?\s*最新更新.+$/, "")
      .sub(/[（\(\[].+?[\]\)）]$/, "")
      .sub(/\.(QD|CS)$/, "")
      .sub(/^·(.+)·$/) { |x| x }

    unless author.ends_with?("..")
      author = author.sub(/^\.?(.+)\.$/) { |x| x }
    end

    author.strip
  end
end
