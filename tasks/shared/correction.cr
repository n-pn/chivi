require "../../src/tabkv/value_map"

module CV::DataRepair
  extend self

  class_getter author_map : ValueMap { ValueMap.new("db/nv_fixes/titles_zh.tsv") }

  def fix_author(author : String, ztitle : String)
    unless author = author_map.fval("#{author}  #{ztitle}") || author_map.fval(author)
      author = author.sub(/(　ˇ第.+章ˇ )?\s*最新更新.+$/, "")
        .sub(/[（\(\[].+?[\]\)）]$/, "")
        .sub(/\.(QD|CS)$/, "")
        .sub(/^·(.+)·$/) { |x| x }

      unless author.ends_with?("..")
        author = author.sub(/^\.?(.+)\.$/) { |x| x }
      end

      author.strip
    end

    author
  end
end
