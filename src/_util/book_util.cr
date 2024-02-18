require "./char_util"

module BookUtil
  DIR = "var/_conf/fixes"

  class_getter zh_authors : Hash(String, String) { load_tsv("authors_zh") }
  class_getter zh_btitles : Hash(String, String) { load_tsv("btitles_zh") }

  def self.load_tsv(name : String)
    hash = {} of String => String

    File.each_line("#{DIR}/#{name}.tsv") do |line|
      next if line.empty?

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

  def self.fix_names(author : String, btitle : String)
    new_author = fix_zname(zh_authors, author, "#{author}  #{btitle}")
    new_btitle = fix_zname(zh_btitles, btitle, "#{btitle}  #{new_author}")

    {new_author, new_btitle}
  end

  @[AlwaysInline]
  def self.fix_author(zname : String) : String
    fix_zname(self.zh_authors, zname, "?")
  end

  @[AlwaysInline]
  def self.fix_btitle(zname : String) : String
    fix_zname(self.zh_btitles, zname, "?")
  end

  @[AlwaysInline]
  def self.fix_zname(known_fixes : Hash(String, String),
                     zname : String, zname_alt : String)
    known_fixes[zname_alt]? || (known_fixes[zname] ||= scrub_name(zname))
  end

  def self.scrub_name(zname : String)
    CharUtil.upcase_canonize(zname)
      .sub(/　*(ˇ第.+章ˇ)?　*(最新更新.+)?$/, "")
      .sub(/^　*(.+?)　*[（［].*?[］）]$/) { |_, x| x[1] }
      .sub(/．(ＱＤ|ＣＳ)$/, "")
  end
end
