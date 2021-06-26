require "../../cutil/text_utils"
require "../../tsvfs/value_map"
require "../../libcv/cvmtl"

module CV::BookUtils
  extend self

  DIR = "db/fixtures"

  class_getter zh_authors : ValueMap { ValueMap.new("#{DIR}/zh_authors.tsv") }
  class_getter vi_authors : ValueMap { ValueMap.new("#{DIR}/vi_authors.tsv") }

  class_getter zh_btitles : ValueMap { ValueMap.new("#{DIR}/zh_btitles.tsv") }
  class_getter vi_btitles : ValueMap { ValueMap.new("#{DIR}/vi_btitles.tsv") }

  def fix_zh_author(author : String, ztitle : String = "")
    if author = zh_authors.fval("#{author}  #{ztitle}") || zh_authors.fval(author)
      return author
    end

    author = author
      # .sub(/(　ˇ第.+章ˇ )?\s*最新更新.+$/, "")
      .sub(/[（\(\[].+?[\]\)）]$/, "")
      .sub(/\.(QD|CS)$/, "")
      .sub(/^·(.+)·$/) { |x| x }

    author = author.sub(/^\.?(.+)\.$/) { |x| x } unless author.ends_with?("..")
    author.strip
  end

  def get_vi_author(author : String)
    vi_authors.fval(author) || hanviet(author)
  end

  def fix_zh_btitle(ztitle : String, author : String = "") : String
    if btitle = zh_btitles.fval("#{ztitle}  #{author}") || zh_btitles.fval(ztitle)
      return btitle
    end

    ztitle = CvUtil.normalize(ztitle)
    ztitle.sub(/[\(\[].+?[\]\)]$/, "").strip
  end

  def get_vi_btitle(ztitle : String) : String
    if vtitle = vi_btitles.fval(ztitle)
      TextUtils.titleize(vtitle)
    else
      hanviet(ztitle)
    end
  end

  def hanviet(input : String, caps : Bool = true)
    return input unless input =~ /\p{Han}/ # return if no hanzi found

    output = Cvmtl.hanviet.translit(input, false).to_s
    caps ? TextUtils.titleize(output) : output
  end

  def convert(input : String, udict = "various")
    cvmtl = Cvmtl.generic(udict)

    input.split(/\r|\n/).map do |line|
      line = line.strip
      line.empty? ? line : cvmtl.cv_plain(line).to_s
    end
  end
end
