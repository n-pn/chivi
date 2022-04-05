require "../shared/bootstrap"

require "tabkv"

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

  record Status, status : Int32, rawstr : String? do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i, rows[1]?)
    end

    def to_tsv
      "#{@status}\t#{@rawstr}"
    end
  end

  record Mftime, utime : Int64, rawstr : String? do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i64, rows[1]?)
    end

    def to_tsv
      "#{@utime}\t#{@rawstr}"
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
end

class CV::NvinfoData
  DIR = "var/nvinfos"

  class_getter authors : Hash(String, Author) do
    query = Author.query.select("id", "zname")

    query.each_with_object({} of String => Author) do |author, output|
      output[author.zname] = author
    end
  end

  def self.get_author(zname : String)
    authors[zname] ||= Author.find({zname: zname}) || begin
      return unless yield
      Author.upsert!(zname)
    end
  end

  def self.get_author(zname : String)
    get_author(zname) { false }
  end

  def self.get_author!(zname : String) : Author
    authors[zname] ||= Author.upsert!(zname)
  end

  def self.stime(file : String)
    File.info(file).modification_time.to_unix
  end

  def self.print_stats(label : String)
    puts "- [seed #{label}] <#{idx.colorize.cyan}>, \
            authors: #{authors.size.colorize.cyan}, \
            nvinfos: #{Nvinfo.query.count.colorize.cyan}, \
            nvseeds: #{Nvseed.query.count.colorize.cyan}"
  end

  ###################

  getter _index : Tabkv(Bindex) { Tabkv(Bindex).new("#{@_wd}/_index.tsv") }

  getter genres : Tabkv(Array(String)) { Tabkv(Array(String)).new("#{@_wd}/genres.tsv") }
  getter intros : Tabkv(Array(String)) { Tabkv(Array(String)).new("#{@_wd}/intros.tsv") }
  getter covers : Tabkv(String) { Tabkv(String).new("#{@_wd}/covers.tsv") }

  getter status : Tabkv(Status) { Tabkv(Status).new("#{@_wd}/status.tsv") }
  getter utimes : Tabkv(Mftime) { Tabkv(Mftime).new("#{@_wd}/utimes.tsv") }

  # for nvseed
  getter chsize : Tabkv(Chsize) { Tabkv(Chsize).new("#{@_wd}/chsize.tsv") }

  getter _wd : String # working directory

  def initialize(@_wd)
  end

  def save!(clean : Bool = false)
    @_index.try(&.save!(clean: clean))

    @genres.try(&.save!(clean: clean))
    @intros.try(&.save!(clean: clean))
    @covers.try(&.save!(clean: clean))

    @status.try(&.save!(clean: clean))
    @utimes.try(&.save!(clean: clean))

    @chsize.try(&.save!(clean: clean))
  end

  def add!(entry, snvid : String, atime : Int64)
    _index.append(snvid, Bindex.new(atime, entry.btitle, entry.author))
    genres.append(snvid, entry.genres)
    intros.append(snvid, entry.bintro)
    covers.append(snvid, entry.bcover)
    utimes.append(snvid, Mftime.new(entry.update_int, entry.update_str))
  end

  def seed!(force : Bool = false)
    _index.data.each_key { |snvid, bindex| seed!(snvid, bindex, force: force) }
  end

  def update_bindex(entry, bindex : Bindex)
    entry.stime = bindex.stime
    entry.btitle = bindex.btitle
    entry.author = bindex.author
  end

  def update_common(entry : Ysbook | Nvseed, snvid : String)
    entry.utime = self.utimes[snvid].utime

    entry.bcover = self.covers[snvid]
    entry.bgenre = self.genres[snvid].join('\t')
    entry.bintro = self.intros[snvid].join('\t')
  end

  def update_nvinfo(nvinfo : Nvinfo, entry : Ysbook | Nvseed)
    nvinfo.set_genres(entry.bgenre.split('\t'))
    nvinfo.set_zintro(entry.bintro.split('\t'))

    nvinfo.set_covers(entry.bcover)
    nvinfo.set_status(entry.status)

    nvinfo.set_utime(entry.utime)
  end

  # def get_scores(snvid : String)
  #   rating[snvid]? || {0, Random.rand(40..50)}
  # end
end
