require "tabkv"
require "./_bootstrap"

require "../../src/_init/init_records"

module CV::NvinfoSeed
  extend self

  class_getter authors = {} of String => Author
  class_getter ratings = Tabkv(Scores).new("var/_common/rating_fix.tsv", :force)

  def get_author(zname : String)
    authors[zname] ||= Author.find({zname: zname}) || return
  end

  def get_author!(zname : String) : Author
    authors[zname] ||= Author.upsert!(zname)
  end

  def get_scores(btitle : String, author : String)
    @@ratings["#{btitle}  #{author}"]? || Scores.rand
  end

  def get_mtime(file : String) : Int64
    File.info?(file).try(&.modification_time.to_unix) || 0_i64
  end

  def fix_names!(entry)
    entry.btitle, entry.author = BookUtil.fix_names(entry.btitle, entry.author)
  end

  def seed!(entry) : Nvinfo
    author = get_author!(entry.author)
    nvinfo = Nvinfo.upsert!(author, entry.btitle)
    yield nvinfo
    save!(nvinfo, entry)
  end

  def save!(nvinfo : Nvinfo, entry)
    nvinfo.set_genres(entry.genres)
    nvinfo.set_zintro(entry.bintro)

    nvinfo.set_covers(entry.bcover)
    nvinfo.set_status(entry.status)

    nvinfo.set_utime(entry.update_int)

    nvinfo.tap(&.save!)
  end

  def log(sname : String, label = "1/1")
    authors = Author.query.count
    nvinfos = Nvinfo.query.count
    nvseeds = Nvseed.query.count

    puts "- [seed-#{sname}] <#{label.colorize.cyan}>, \
            authors: #{authors.colorize.cyan}, \
            nvinfos: #{nvinfos.colorize.cyan}, \
            nvseeds: #{nvseeds.colorize.cyan}"
  end
end
