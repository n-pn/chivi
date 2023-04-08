require "json"
# require "tabkv"

require "../../_util/text_util"
require "../../mtapp/v0_core"

module CV::BookUtil
  extend self

  DIR = "var/books/fixes"

  class_getter zh_authors : Hash(String, String) { load_tsv("authors_zh") }
  class_getter zh_btitles : Hash(String, String) { load_tsv("btitles_zh") }

  # class_getter vi_authors : Hash(String, String) { load_tsv("authors_vi") }
  # class_getter vi_btitles : Tabkv(String) { load_tsv("btitles_vi") }

  def load_tsv(name : String)
    hash = {} of String => String

    File.each_line("#{DIR}/#{name}.tsv") do |line|
      rows = line.split('\t')
      key = rows[0]
      if val = rows[1]?
        hash[key] = val
      else
        hash.delete(key)
      end
    end

    hash
  end

  #############

  def fix_names(btitle : String, author : String)
    new_author = fix_name(:author, "#{author}  #{btitle}", author)
    new_btitle = fix_name(:btitle, "#{btitle}  #{new_author}", "#{btitle}  #{author}", btitle)

    {new_btitle, new_author}
  end

  def fix_name(type : Symbol, *keys : String)
    map = type == :author ? zh_authors : zh_btitles
    keys.each { |key| map[key]?.try { |x| return x } }
    clean_name(keys[-1], type)
  end

  def clean_name(name : String, type = :btitle)
    name = TextUtil.normalize(name)
    name = name.sub(/\s*(ˇ第.+章ˇ)?\s*(最新更新.+)?$/, "")
    name = name.sub(/^\s*(.+?)\s*[（【\(\[].*?[）】\)\]]$/) { |_, x| x[1] }

    return name unless type == :author
    name.sub(/\.(QD|CS)$/, "").sub(/^·+(.+)·+$/) { |_, x| x[1] }
  end

  def scrub(name : String, delimit = "-")
    query =~ /\p{Han}/ ? scrub_zname(name) : scrub_vname(name, delimit)
  end

  def scrub_zname(zname : String) : String
    zname.gsub(/[^\p{L}\p{N}]/, "")
  end

  # def scrub_vname(vname : String, delimit = " ") : String
  #   res = String::Builder.new
  #   acc = String::Builder.new

  #   vname = scrub_tones(vname)

  #   vname.each_char do |char|
  #     if char.ascii_alphanumeric?
  #       acc << char
  #     elsif !acc.empty?
  #       res << delimit unless res.empty?
  #       res << acc.to_s
  #       acc = String::Builder.new
  #     end
  #   end

  #   unless acc.empty?
  #     res << delimit unless res.empty?
  #     res << acc.to_s
  #   end

  #   res.to_s
  # end

  # def make_slug(name : String)
  #   "-#{scrub_vname(name, "-")}-"
  # end

  #######################

  def split_lines(input : String)
    input.split(/\R/).map!(&.strip).reject!(&.empty?)
  end

  def tl_name(input : String)
    MT::V0Core.tl_hvname(input)
  end
end
