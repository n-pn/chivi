require "./seed_nvinfo"

class CV::YsbookSeed
  def init!
  end

  def seed!
  end

  def seed!(input : SeedNvinfo)
  end

  def load_ysbook(seed : SeedNvinfo, snvid : String, force = false)
    btitle, author_zname = bindex.fix_names
    return if btitle.blank? || author_zname.blank?
    return unless ysbook = load_ysbook()

    #####

    rating = seed.rating[snvid]
    ystats = seed.ystats[snvid]

    if ysbook = Ysbook.get(snvid.to_i64)
      return unless force || ysbook.stime < bindex.stime
    else
      author = SeedNvinfo.get_author(author_zname) do
        rating.voters > 9 || ystats.crit_count > 3 || ystats.list_count > 1
      end

      return unless author
      ysbook = Ysbook.upsert!(snvid.to_i64)
    end

    {ysbook, rating, ystats}
  end
end
