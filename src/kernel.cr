require "./shared/*"
require "./engine/*"
require "./filedb/*"
require "./filedb/nvinit/rm_text"

require "./_oldcv/kernel/bookdb"
require "./_oldcv/kernel/models/chap_list"

module CV::Kernel
  extend self

  def load_chlist(info : Oldcv::BookInfo, seed : String, mode : Int32 = 0) : Tuple(Oldcv::ChapList, Int64)?
    return unless sbid = info.seed_sbids[seed]?

    chlist = Oldcv::ChapList.preload_or_create!(info.ubid, seed)
    expiry = mode > 0 ? (Time.utc - 5.minutes) : Time.utc(2010, 1, 1)

    expiry -= 10.years unless remote?(seed)

    if Oldcv::ChapList.outdated?(info.ubid, seed, expiry)
      remote = Oldcv::SeedInfo.new(seed, sbid, expiry: expiry, freeze: true)

      Oldcv::BookDB.update_info(info, remote)
      info.save! if info.changed?

      chlist.merge!(remote.chapters, dirty: mode < 2)
    end

    tranlate_chlist(chlist, force: mode > 0)
    chlist.save! if chlist.changed?

    {chlist, info.seed_mftimes[seed]}
  end

  def tranlate_chlist(chlist : Oldcv::ChapList, force : Bool = false)
    chlist.tap do |x|
      x.update_each do |chap|
        chap.tap &.translate!(chlist.ubid, force: force)
      end
    end
  end

  # # modes:
  # 0 => load saved chap_text
  # 1 => load saved chap_text then convert
  # 2 => fetch text from external hosts then convert

  def load_chtext(seed : String, sbid : String, scid : String,
                  dict : String = "various", mode : Int32 = 0)
    chtext = Zhtext.load(seed, sbid, scid)
    return chtext if mode == 0 && recent?(chtext.cv_mtime, 3.hours)

    lines = chtext.zh_lines

    if remote?(seed) && (mode > 1 || lines.empty?)
      source = RmText.init(seed, sbid, scid)
      lines = [source.title].concat(source.paras)
      chtext.tap(&.zh_lines = lines).save!
    end

    chtext.tap do |x|
      if lines.empty?
        x.cv_trans = ""
      else
        x.cv_trans = Oldcv::Engine.cv_mixed(lines, dict).map(&.to_s).join("\n")
      end

      x.cv_mtime = Time.utc.to_unix
    end
  end

  REMOTE_SEEDS = {
    "hetushu", "rengshu", "xbiquge",
    "nofff", "zhwenpg", "5200",
    "biquge5200", "duokan8",
    # "shubaow", "69shu", "paoshu8"
  }

  def remote?(seed : String)
    REMOTE_SEEDS.includes?(seed)
  end

  def recent?(mftime : Int64, span = 3.hours)
    mftime >= (Time.utc - span).to_unix
  end
end
