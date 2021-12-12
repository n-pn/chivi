require "json"
require "tabkv"

module CV::NvUtil
  extend self

  DIR = "var/nvinfos/fixed"

  class_getter zh_authors : Tabkv { Tabkv.new("#{DIR}/authors_zh.tsv") }
  class_getter vi_authors : Tabkv { Tabkv.new("#{DIR}/authors_vi.tsv") }

  class_getter zh_btitles : Tabkv { Tabkv.new("#{DIR}/btitles_zh.tsv") }
  class_getter vi_btitles : Tabkv { Tabkv.new("#{DIR}/btitles_vi.tsv") }

  def fix_names(btitle : String, author : String)
    new_author = fix_name(:author, "#{author}  #{btitle}", author)
    new_btitle = fix_name(:btitle, "#{btitle}  #{new_author}", "#{btitle}  #{author}", btitle)

    {new_btitle, new_author}
  end

  def fix_name(type : Symbol, *keys : String)
    map = type == :author ? zh_authors : zh_btitles
    keys.each { |key| map.fval(key).try { |x| return x } }
    clean_name(keys[-1], type)
  end

  def clean_name(name : String, type = :btitle)
    name = name.chars.map { |x| NORMALIZE[x]? || x }.join
    name = name.sub(/[（【\(\[].+?[）】\)\]](　ˇ第.+章ˇ )?\s*(最新更新.+)?$/, "").strip
    return name unless type == :author
    name.sub(/\.(QD|CS)$/, "").sub(/^·+(.+)·+$/) { |x| x }
  end

  NORMALIZE = begin
    lines = File.read_lines("#{__DIR__}/nvutil/normalize.tsv")
    lines.each_with_object({} of Char => Char) { |x, h| h[x[0]] = h[x[2]] }
  end

  def scrub(name : String, delimit = "-")
    query =~ /\p{Han}/ ? scrub_zname(name) : scrub_vname(name, delimit)
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

    unless acc.empty?
      res << delimit unless res.empty?
      res << acc.to_s
    end

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

# puts CV::NvUtil.scrub_zname("9205.第9205章 test 番外 test??!!")
# puts CV::NvUtil.scrub_vname("sd9205.test 番外 12 test2??!! tiếng việt=", "-")
