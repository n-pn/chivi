require "./shared/*"
require "./engine/*"
require "./filedb/*"

require "./_oldcv/kernel/bookdb"
require "./_oldcv/kernel/chapdb"
require "./_oldcv/kernel/models/chap_text"

module CV::Kernel
  extend self

  def load_list(info : Oldcv::BookInfo, seed : String, mode = 0) : Tuple(Oldcv::ChapList, Int64)?
    return unless sbid = info.seed_sbids[seed]?

    chlist = Oldcv::ChapList.preload_or_create!(info.ubid, seed)
    expiry = mode > 0 ? (Time.utc - 5.minutes) : Time.utc(2010, 1, 1)

    expiry -= 10.years unless remote?(seed)

    if Oldcv::ChapList.outdated?(info.ubid, seed, expiry)
      remote = Oldcv::SeedInfo.new(seed, sbid, expiry: expiry, freeze: true)

      Oldcv::BookDB.update_info(info, remote)
      info.save! if info.changed?

      Oldcv::ChapDB.update_list(chlist, remote, dirty: mode < 2, force: mode > 0)
      chlist.save! if chlist.changed?
    else
      Oldcv::ChapDB.translate_list(chlist, force: mode > 0)
    end

    {chlist, info.seed_mftimes[seed]}
  end

  # # modes:
  # 0 => load saved chap_text
  # 1 => load saved chap_text then convert
  # 2 => fetch text from external hosts then convert

  def get_text(bhash : String, sname : String, s_bid : String, s_cid : String, mode = 0)
    chtext = Oldcv::ChapText.load(sname, s_bid, s_cid)
    return chtext if mode == 0 && recent?(chtext.cv_time, 2.hours)

    zh_data = mode < 2 ? chtext.zh_data : [] of String

    if zh_data.empty?
      if remote?(sname)
        source = Oldcv::SeedText.new(sname, s_bid, s_cid, freeze: true)
        zh_data = [source.title].concat(source.paras)
        chtext.tap(&.zh_data = zh_data).save!
      end
    end

    chtext.tap do |x|
      if zh_data.empty?
        x.cv_text = ""
      else
        x.cv_text = Oldcv::Engine.cv_mixed(zh_data, bhash).map(&.to_s).join("\n")
      end
      x.cv_time = Time.utc.to_unix_ms
    end
  end

  SEEDS = {
    "hetushu", "rengshu", "xbiquge",
    "nofff", "paoshu8", "69shu",
    "zhwenpg", "5200", "biquge5200",
    "duokan8", "shubaow",
  }

  def remote?(seed : String)
    SEEDS.includes?(seed)
  end

  def recent?(mftime : Int64, span = 1.hours)
    mftime > (Time.utc - span).to_unix_ms
  end
end
