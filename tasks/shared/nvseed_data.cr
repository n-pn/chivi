require "./nvinfo_data"

class CV::NvseedData < CV::NvinfoData
  def add!(entry, snvid : String, stime : Int64)
    super

    status.append(snvid, Status.new(entry.status_int, entry.status_str))
  end

  def seed!(force : Bool = false, label = "-")
    super(force: force)
    NvinfoData.print_stats(@sname, label: label)
  end

  getter force_author : Bool { @sname.in?("zxcs_me", "hetushu", "users", "staff", "zhwenpg") }
  getter force_nvinfo : Bool { force_author || @sname.in?("rengshu") }

  def get_nvinfo(author : Author, btitle : String)
    force_nvinfo ? Nvinfo.upsert!(author, btitle) : Nvinfo.get(author, btitle)
  end

  def seed_entry!(snvid : String, bindex : Bindex, force : Bool = false)
    btitle, author_zname = bindex.fix_names
    return if btitle.blank? || author_zname.blank?

    return unless author = NvinfoData.get_author(author_zname, force: force_author)
    return unless nvinfo = get_nvinfo(author, btitle)

    nvseed = Nvseed.upsert!(nvinfo, @sname, snvid)
    return unless force || nvseed.stime < bindex.stime

    update_bindex(nvseed, bindex)
    update_common(nvseed, snvid)
    update_nvseed(nvseed, snvid)

    if nvinfo.voters < 10
      rating = get_scores(btitle, author_zname)
      nvinfo.fix_scores!(rating.voters, rating.voters &* rating.rating)
    end

    update_nvinfo(nvinfo, nvseed)
    nvinfo.tap(&.add_nvseed(nvseed.zseed)).save!
  end

  def update_nvseed(nvseed : Nvseed, snvid : String)
    unless last_chap = self.last_chap(snvid)
      chap_list = RemoteInfo.new(sname, snvid, ttl: 10.years).chap_infos
      nvseed._repo.store!(chap_list, reset: true)
      last_chap = chap_list.last
    end

    self.status[snvid]?.try { |x| nvseed.update_status(x.status) }
    nvseed.tap(&.update_latest(last_chap)).save!
  end

  def last_chap(snvid : String) : ChInfo?
    files = Dir.glob("var/chtexts/#{@sname}/#{snvid}/*.tsv")
    files.sort_by! { |x| File.basename(x, ".tsv").to_i }

    return unless last_file = files.last?
    ChList.new(last_file).data.max_by(&.[0])[1]
  rescue err
    puts err
  end

  RATING_FIX = Tabkv(Rating).new("var/zhinfos/rating_fix.tsv", :force)

  def get_scores(btitle : String, author : String)
    RATING_FIX["#{btitle}  #{author}"]?.try { |x| return x }

    if @sname.in?("hetushu", "zxcs_me")
      Rating.new(Random.rand(20..30), Random.rand(50..60))
    else
      Rating.new(Random.rand(10..20), Random.rand(40..50))
    end
  end
end
