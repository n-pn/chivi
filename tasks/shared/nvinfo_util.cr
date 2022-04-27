require "../shared/bootstrap"

module CV
  record Bindex, stime : Int64, btitle : String, author : String do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i64, rows[1], rows[2])
    end

    def to_tsv
      "#{@stime}\t#{@btitle}\t#{@author}"
    end

    def fix_names
      BookUtil.fix_names(@btitle, @author)
    end
  end

  record Status, status : Int32, rawstr : String do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i, rows[1]? || rows[0])
    end

    def to_tsv
      "#{@status}\t#{@rawstr}"
    end
  end

  record Mftime, mftime : Int64, rawstr : String? do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i64, rows[1]?)
    end

    def to_tsv
      "#{@mftime}\t#{@rawstr}"
    end
  end

  record Chsize, chap_count : Int32, last_schid : String do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i, rows[1].to_i)
    end

    def to_tsv
      "#{@chap_count}\t#{@last_schid}"
    end
  end

  record Rating, voters : Int32, rating : Int32 do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i, rows[1].to_i)
    end

    def to_tsv
      "#{@voters}\t#{@rating}"
    end
  end
end

module CV::NvinfoUtil
  extend self

  class_getter authors : Hash(String, Author) do
    output = {} of String => Author

    Author.query.select("id", "zname").each do |author|
      output[author.zname] = author
    end

    output
  end

  class_getter btitles : Hash(String, Btitle) do
    output = {} of String => Btitle

    Btitle.query.select("id", "zname").each do |btitle|
      output[btitle.zname] = btitle
    end

    output
  end

  def get_author(zname : String, force = false)
    self.authors[zname] ||= Author.find({zname: zname}) || begin
      return unless force
      Author.upsert!(zname)
    end
  end

  def get_btitle(zname : String, force = false)
    self.btitles[zname] ||= Btitle.find({zname: zname}) || begin
      return unless force
      Btitle.upsert!(zname)
    end
  end

  def mtime(file : String)
    File.info?(file).try(&.modification_time.to_unix)
  end

  def print_stats(label : String)
    puts "- <#{label.colorize.cyan}>, \
          authors: #{authors.size.colorize.cyan}, \
          nvinfos: #{Nvinfo.query.count.colorize.cyan}, \
          ysbooks: #{Ysbook.query.count.colorize.cyan}, \
          nvseeds: #{Nvseed.query.count.colorize.cyan}"
  end
end
