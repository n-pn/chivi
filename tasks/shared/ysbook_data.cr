require "./nvinfo_data"
require "./raw_ysbook"

module CV
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

  record Ystats, word_count : Int32, crit_count : Int32, list_count : Int32 do
    def self.from_tsv(rows : Array(String))
      new(rows[0].to_i, rows[1].to_i, rows[2].to_i)
    end

    def to_tsv
      {@word_count, @crit_count, @list_count}.join('\t')
    end
  end

  record Origin, pub_link : String, pub_name : String do
    def self.from_tsv(rows : Array(String))
      new(rows[0], rows[1])
    end

    def to_tsv
      "#{@pub_link}\t#{@pub_name}"
    end
  end
end

class CV::YsbookData < CV::NvinfoData
  getter rating : Tabkv(Rating) { Tabkv(Rating).new("#{@_wd}/rating.tsv") }
  getter ystats : Tabkv(Ystats) { Tabkv(Ystats).new("#{@_wd}/ystats.tsv") }
  getter origin : Tabkv(Origin) { Tabkv(Origin).new("#{@_wd}/origin.tsv") }

  def add!(entry, snvid : String, stime : Int64)
    super

    rating.append(snvid, Rating.new(entry.voters, entry.rating))
    status.append(snvid, Status.new(entry.status, entry.shield.to_s))
    origin.append(snvid, Origin.new(entry.pub_link, entry.pub_name))
    ystats.append(snvid, Ystats.new(entry.word_count, entry.crit_count, entry.list_total))
  end

  def save!(clean : Bool = false)
    super

    @rating.try(&.save!(clean: clean))
    @origin.try(&.save!(clean: clean))
    @ystats.try(&.save!(clean: clean))
  end

  def seed!(force : Bool = false, index : Int32 = 1)
    super(force: force)
    NvinfoData.print_stats("yousuu", index: index)
  end

  def seed_entry!(snvid : String, bindex : Bindex, force : Bool = false)
    btitle, author_zname = bindex.fix_names
    return if btitle.blank? || author_zname.blank?

    id = snvid.to_i64
    rating = self.rating[snvid]
    ystats = self.ystats[snvid]

    if ysbook = Ysbook.find({id: id})
      return unless force || ysbook.stime < bindex.stime || ysbook.voters < rating.voters
      author = NvinfoData.get_author!(author_zname)
    else
      force = rating.voters > 9 || ystats.crit_count > 4 || ystats.list_count > 1
      return unless author = NvinfoData.get_author(author_zname, force: force)
      ysbook = Ysbook.new({id: id})
    end

    update_bindex(ysbook, bindex)
    update_common(ysbook, snvid)
    update_ysbook(ysbook, rating, ystats)

    nvinfo = Nvinfo.upsert!(author, btitle)
    upsert_nvinfo(nvinfo, ysbook)

    ysbook.save!
  end

  def update_ysbook(ysbook : Ysbook, rating : Rating, ystats : Ystats)
    ysbook.voters = rating.voters
    ysbook.scores = rating.voters &* rating.rating

    ysbook.list_total = ystats.list_count
    ysbook.crit_total = ystats.crit_count

    ysbook.list_count = ystats.list_count if ysbook.list_count == 0
    ysbook.crit_count = ystats.crit_count if ysbook.crit_count == 0

    if states = self.status[ysbook.id.to_s]?
      ysbook.status = states.status
      ysbook.shield = states.rawstr.to_i
    end

    if origin = self.origin[ysbook.id.to_s]?
      ysbook.pub_name = origin.pub_name
      ysbook.pub_link = origin.pub_link
    end
  end

  def upsert_nvinfo(nvinfo : Nvinfo, ysbook : Ysbook)
    if nvinfo.ysbook_id > 0 && nvinfo.ysbook_id != ysbook.id
      old_ysbook = Ysbook.find!({id: nvinfo.ysbook_id})
      return if ysbook.voters <= old_ysbook.voters

      puts "!! override: #{old_ysbook.id} (#{old_ysbook.voters}) \
               => #{ysbook.id} (#{ysbook.voters})".colorize.yellow
    end

    nvinfo.ysbook_id = ysbook.id
    ysbook.nvinfo_id = nvinfo.id

    update_nvinfo(nvinfo, ysbook)
    nvinfo.set_shield(ysbook.shield)
    nvinfo.fix_scores!(ysbook.voters, ysbook.scores)

    nvinfo.save!
  end
end
