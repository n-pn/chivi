require "../shared/bootstrap"

require "tabkv"

module CV
  record Bindex, stime : Int64, btitle : String, author : String do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i64, rows[1], rows[2])
    end

    def to_tsv
      "#{@stime}\#{@btitle}\t#{@author}"
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

  record Mftime, update : Int64, rawstr : String? do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i64, rows[1]?)
    end

    def to_tsv
      "#{@update}\t#{@rawstr}"
    end
  end

  record Rating, voters : Int32, rating : Int32 do
    def self.rand
      {Random.rand(25..50), Random.rand(40..50)}
    end

    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i, rows[1].to_i)
    end

    def to_tsv
      "#{@voters}\t#{@rating}"
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

  record Origin, pub_link : String, pub_name : String? do
    def self.from_tsv(rows : Array(String))
      pub_link = rows[0]
      pub_name = rows[1]? || extract_name(pub_link)
      new(pub_link, pub_name)
    end

    def to_tsv
      "#{@pub_link}\t#{@pub_name}"
    end
  end

  record Ystats, word_count : Int32, crit_count : Int32, list_count : Int32 do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i, rows[1].to_i, rows[2].to_i)
    end

    def to_tsv
      {@word_count, @crit_count, @list_count}.join('\t')
    end
  end
end

class CV::NvinfoData
  DIR = "var/nvinfos"

  ###################

  getter _index : Tabkv(Bindex) { Tabkv(Bindex).new("#{@_wd}/_index.tsv") }

  getter genres : Tabkv(Array(String)) { Tabkv(Array(String)).new("#{@_wd}/genres.tsv") }
  getter intros : Tabkv(Array(String)) { Tabkv(Array(String)).new("#{@_wd}/intros.tsv") }
  getter covers : Tabkv(String) { Tabkv(String).new("#{@_wd}/covers.tsv") }

  getter status : Tabkv(Status) { Tabkv(Status).new("#{@_wd}/status.tsv") }
  getter rating : Tabkv(Rating) { Tabkv(Rating).new("#{@_wd}/rating.tsv") }
  getter utimes : Tabkv(Mftime) { Tabkv(Mftime).new("#{@_wd}/utimes.tsv") }

  # for nvseed
  getter chsize : Tabkv(Chsize) { Tabkv(Chsize).new("#{@_wd}/chsize.tsv") }

  # for yousuu
  getter origin : Tabkv(Origin) { Tabkv(Origin).new("#{@_wd}/origin.tsv") }
  getter ystats : Tabkv(Origin) { Tabkv(Origin).new("#{@_wd}/ystats.tsv") }
  getter shield : Tabkv(Int32) { Tabkv(Int32).new("#{@_wd}/shield.tsv") }

  getter _wd : String # working directory

  def initialize(@sname : String, slice : String | Int32)
    @_wd = "#{DIR}/#{@sname}/#{slice}"
    Dir.mkdir_p(@_wd)
  end

  def save!(clean : Bool = false)
    @_index.try(&.save!(clean: clean))

    @genres.try(&.save!(clean: clean))
    @intros.try(&.save!(clean: clean))
    @covers.try(&.save!(clean: clean))

    @status.try(&.save!(clean: clean))
    @utimes.try(&.save!(clean: clean))

    @chsize.try(&.save!(clean: clean))
    @rating.try(&.save!(clean: clean))
  end

  def add!(entry, snvid : String, atime : Int64)
    _index.append(snvid, Bindex.new(atime, entry.btitle, entry.author))

    genres.append(snvid, entry.genres)
    intros.append(snvid, entry.bintro)
    covers.append(snvid, entry.bcover)

    mftime.append(snvid, Mftime.new(entry.update_int, entry.update_str))
    status.append(snvid, Status.new(entry.status_int, entry.status_str))

    # if entry.is_a?(YsbookInit)
    #   origin.append(snvid, Origin.from_tsv([entry.pub_link]))
    # end
  end

  # def seed!(force : Bool = false)
  #   case @sname
  #   when "yousuu"
  #     _index.data.each_key { |snvid, bindex| upsert_ysbook(snvid, bindex) }
  #   else
  #     _index.data.each_key { |snvid, bindex| upsert_nvseed(snvid, bindex) }
  #   end
  # end

  # def seed_ysbook(snvid : String, force : Bool = false)
  #   bindex = sellf._index[snvid]?
  #   btitle, author_zname = bindex.fix_names

  #   return if btitle.blank? || author_zname.blank?
  #   return unless ysbook = load_ysbook()

  #   #####
  #   ysbook.set_bindex(bindex)
  #   ysbook.set_rating(rating)
  #   ysbook.set_ystats(ystats)
  #   ysbook.set_origin(self.origin[snvid])

  #   ysbook.utime = self.utimes[snvid].update
  #   ysbook.status = self.status[snvid].status

  #   #####

  #   nvinfo = upsert_nvinfo(snvid, btitle , author )

  #   ysbook.tap(&.nvinfo_id = nvinfo.id).save!

  # end

  # def upsert_nvinfo(snvid : String, btitle : String, author : Author)

  # end

  # def init_nvinfo(ysbook : Ysbook, btitle : String, author : Author)
  #   nvinfo = Nvinfo.upsert!(btitle, author)

  #   if old_ysbook = load_ysbook(nvinfo.ysbook_id, ysbook.id)
  #     return nvinfo if ysbook.voters <= old_ysbook.voters

  #     puts "!! override: #{old_ysbook.id} (#{old_ysbook.voters}) \
  # => #{entry._id} (#{entry.voters})".colorize.yellow
  #   end

  #   nvinfo.ysbook_id = ysbook.id

  #   nvinfo.set_shield(self.shield[snvid]? || 0)
  #   nvinfo.fix_scores!(ysbook.voters, ysbook.scores)

  #   nvinfo
  # end

  # def get_scores(snvid : String)
  #   rating[snvid]? || {0, Random.rand(40..50)}
  # end
end
