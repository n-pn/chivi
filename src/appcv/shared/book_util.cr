require "json"
require "tabkv"

module CV::BookUtil
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
    name = name.sub(/[（【\(\[].+?[）】\)\]](\s*ˇ第.+章ˇ\s*)?\s*(最新更新.+)?$/, "").strip
    return name unless type == :author
    name.sub(/\.(QD|CS)$/, "").sub(/^·+(.+)·+$/) { |x| x }
  end

  NORMALIZE = begin
    lines = File.read_lines("#{__DIR__}/book_util/normalize.tsv")
    lines.each_with_object({} of Char => Char) do |line, hash|
      hash[line[0]] = line[2]
    end
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

    vname = scrub_tones(vname)
    vname.each_char do |char|
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

  def make_slug(name : String)
    String.build do |io|
      io << '-' << scrub_vname(name, "-") << '-'
    end
  end

  def hanviet(input : String, caps : Bool = true) : String
    return input unless input =~ /\p{Han}/ # return if no hanzi found

    output = MtCore.hanviet_mtl.translit(input, false).to_s
    caps ? TextUtil.titleize(output) : output
  end

  def convert(input : String, udict = "combine") : Array(String)
    lines = TextUtil.split_html(input)
    convert(lines, udict)
  end

  def convert(lines : Array(String), udict = "combine") : Array(String)
    cvmtl = MtCore.generic_mtl(udict)
    lines.map! { |line| cvmtl.cv_plain(line).to_s }
  end

  ###################

  def author_vname(author : String) : String
    vi_authors.fval(author) || hanviet(author)
  end

  def btitle_vname(zname : String, bdict : String = "combine") : String
    vname = vi_btitles.fval(zname) || btitle_vname_mtl(zname, bdict)
    TextUtil.titleize(vname)
  end

  def btitle_vname_mtl(zname : String, bdict : String) : String
    cvmtl = MtCore.generic_mtl(bdict)

    NAME_PREFIXES.each do |key, val|
      next unless zname.starts_with?(key)
      return val + cvmtl.translate(zname[key.size..])
    end

    cvmtl.translate(zname)
  end

  NAME_PREFIXES = {
    "火影之" => "NARUTO: ",
    "民国之" => "Dân quốc: ",
    "三国之" => "Tam Quốc: ",
    "综漫之" => "Tổng mạn: ",
    "娱乐之" => "Giải trí: ",
    "重生之" => "Trùng sinh: ",
    "穿越之" => "Xuyên qua: ",
    "复活之" => "Phục sinh: ",
    "网游之" => "Game online: ",

    "哈利波特之" => "Harry Potter: ",
    "网游三国之" => "Tam Quốc game online: ",
  }
end

# puts CV::BookUtil.scrub_zname("9205.第9205章 test 番外 test??!!")
# puts CV::BookUtil.scrub_vname("sd9205.test 番外 12 test2??!! tiếng việt=", "-")
