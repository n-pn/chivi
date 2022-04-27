require "../shared/nvinfo_util"

class CV::ZhinfoData
  alias TabAS = Tabkv(Array(String))

  ################

  getter _index : Tabkv(Bindex) { Tabkv(Bindex).new("#{@w_dir}/_index.tsv") }

  getter bintro : TabAS { TabAS.new("#{@w_dir}/bintro.tsv") }
  getter genres : TabAS { TabAS.new("#{@w_dir}/genres.tsv") }
  getter bcover : Tabkv(String) { Tabkv(String).new("#{@w_dir}/bcover.tsv") }

  getter status : Tabkv(Status) { Tabkv(Status).new("#{@w_dir}/status.tsv") }
  getter mftime : Tabkv(Mftime) { Tabkv(Mftime).new("#{@w_dir}/mftime.tsv") }
  getter chsize : Tabkv(Chsize) { Tabkv(Chsize).new("#{@w_dir}/chsize.tsv") }

  def initialize(@sname : String, @w_dir : String)
    @force_author = @sname.in?("zxcs_me", "hetushu", "users", "staff", "zhwenpg")
    @force_btitle = @force_author || @sname.in?("rengshu", "ptwzx", "69shu")
  end

  def save!(clean : Bool = false)
    @_index.try(&.save!(clean: clean))

    @genres.try(&.save!(clean: clean))
    @bintro.try(&.save!(clean: clean))
    @bcover.try(&.save!(clean: clean))

    @status.try(&.save!(clean: clean))
    @mftime.try(&.save!(clean: clean))

    @chsize.try(&.save!(clean: clean))
  end

  def add!(entry, snvid : String, stime : Int64)
    _index.append(snvid, Bindex.new(stime, entry.btitle, entry.author))

    bintro.append(snvid, entry.bintro)
    genres.append(snvid, entry.genres)
    bcover.append(snvid, entry.bcover)

    mftime.append(snvid, Mftime.new(entry.update_int, entry.update_str))
    status.append(snvid, Status.new(entry.status_int, entry.status_str))
  end

  def get_nvinfo(author_zh : String, btitle_zh : String)
    return if btitle_zh.blank? || author_zh.blank?

    return unless author = NvinfoUtil.get_author(author_zh, force: @force_author)
    return unless btitle = NvinfoUtil.get_btitle(btitle_zh, force: @force_btitle)

    Nvinfo.upsert!(author, btitle)
  end

  def seed!(force : Bool = true, label : String = "-/-")
    _index.data.each { |snvid, bindex| seed_entry!(snvid, bindex, force: force) }
    NvinfoUtil.print_stats("#{@sname}/#{label}")
  end

  def seed_entry!(snvid : String, bindex : Bindex, force : Bool = false)
    btitle_zh, author_zh = bindex.fix_names
    return unless nvinfo = get_nvinfo(author_zh, btitle_zh)

    nvseed = Nvseed.upsert!(nvinfo, @sname, snvid)
    return unless force || nvseed.stime < bindex.stime

    nvseed.stime = bindex.stime

    nvseed.btitle = bindex.btitle
    nvseed.author = bindex.author

    nvseed.set_genres(self.genres[snvid], force: force)
    nvseed.set_bintro(self.bintro[snvid], force: force)
    nvseed.set_bcover(self.bcover[snvid], force: force)
    nvseed.set_mftime(self.mftime[snvid].mftime, force: force)
    nvseed.set_status(self.status[snvid].status, force: force)
    nvseed.fix_latest(force: force)

    if nvinfo.voters < 10
      voters, rating = get_scores(btitle_zh, author_zh)
      nvinfo.fix_scores!(voters, voters &* rating)
    end

    nvinfo.tap(&.add_nvseed(nvseed.zseed)).save!
  end

  RATING_FIX = Tabkv(Rating).new("var/zhinfos/rating_fix.tsv", :force)

  def get_scores(btitle : String, author : String) : {Int32, Int32}
    if fixed = RATING_FIX["#{btitle}  #{author}"]?
      {fixed.voters, fixed.rating}
    elsif @sname.in?("hetushu", "zxcs_me")
      {Random.rand(20..30), Random.rand(50..60)}
    else
      {Random.rand(10..20), Random.rand(40..50)}
    end
  end
end