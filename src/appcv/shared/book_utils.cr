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

  def find_alt(map : ValueMap, key1 : String, key2 : String)
    map.fval(key1) || map.fval(key2)
  end

  def fix_zh_author(author : String, ztitle : String = "") : String
    zh_authors.fval_alt("#{author}  #{ztitle}", author) || begin
      output = author.sub(/(　ˇ第.+章ˇ )?\s*最新更新.+$/, "")
      output = clean_name(output).sub(/\.(QD|CS)$/, "").sub(/^·(.+)·$/) { |x| x }
      output = output.sub(/^\.?(.+)\.$/) { |x| x } unless output.ends_with?("..")
      output.strip
    end
  end

  def get_vi_author(author : String) : String
    vi_authors.fval(author) || hanviet(author)
  end

  def fix_zh_btitle(ztitle : String, author : String = "") : String
    zh_btitles.fval_alt("#{ztitle}  #{author}", ztitle) || begin
      output = CvUtil.normalize(ztitle).join
      clean_name(output)
    end
  end

  private def clean_name(name : String)
    name.sub(/[（【\(\[].+?[）】\)\]]$/, "").strip
  end

  def get_vi_btitle(ztitle : String) : String
    return "" unless vtitle = vi_btitles.fval(ztitle)
    TextUtils.titleize(vtitle)
  end

  def hanviet(input : String, caps : Bool = true) : String
    return input unless input =~ /\p{Han}/ # return if no hanzi found

    output = Cvmtl.hanviet.translit(input, false).to_s
    caps ? TextUtils.titleize(output) : output
  end

  def convert(input : String, udict = "various") : Array(String)
    cvmtl = Cvmtl.generic(udict)

    input.split(/\r|\n/).map do |line|
      line = line.strip
      line.empty? ? line : cvmtl.cv_plain(line).to_s
    end
  end

  def scrub_zname(zname : String) : String
    zname.gsub(/[^\p{L}\p{N}]/, "")
  end

  def scrub_vname(vname : String, delimit = " ") : String
    res = String::Builder.new
    acc = String::Builder.new

    scrub_tones(vname).each_char do |char|
      if char.ascii_alphanumeric?
        acc << char
      elsif !acc.empty?
        res << delimit unless res.empty?
        res << acc.to_s
        acc = String::Builder.new
      end
    end

    res << delimit << acc.to_s unless acc.empty?
    res.to_s
  end

  def scrub_tones(vname : String) : String
    vname.downcase
      .tr("áàãạảăắằẵặẳâầấẫậẩ", "a")
      .tr("éèẽẹẻêếềễệể", "e")
      .tr("íìĩịỉ", "i")
      .tr("óòõọỏôốồỗộổơớờỡợở", "o")
      .tr("úùũụủưứừữựử", "u")
      .tr("ýỳỹỵỷ", "y")
      .tr("đ", "d")
  end
end

# puts CV::BookUtils.scrub_zname("9205.第9205章 test 番外 test??!!")
# puts CV::BookUtils.scrub_vname("sd9205.test 番外 12 test2??!! tiếng việt=", "-")
