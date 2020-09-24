require "file_utils"
require "./appcv/*"

module Appcv
  extend self

  def gen_expiry(status)
    case status
    when 0
      6.hours
    when 1
      6.weeks
    else
      6.months
    end
  end

  def load_list(info : BookInfo, seed : String, mode = 0) : Tuple(ChapList, Int64)?
    return unless sbid = info.seed_sbids[seed]?

    chlist = ChapList.get_or_create(info.ubid, seed)
    expiry = mode > 0 ? (Time.utc - 5.minutes) : Time.unix_ms(info.mftime)

    # jx_la is dead :()
    expiry -= 1.years if seed == "jx_la"

    if ChapList.outdated?(info.ubid, seed, expiry)
      remote = SeedInfo.new(seed, sbid, expiry: expiry, freeze: false)

      BookDB.update_info(info, remote)
      info.save! if info.changed?

      ChapDB.update_list(chlist, remote, dirty: mode < 2, force: mode > 0)
      chlist.save! if chlist.changed?
    else
      ChapDB.translate_list(chlist, force: mode > 0)
    end

    {chlist, info.seed_mftimes[seed]}
  end

  # # modes:
  # 0 => load saved chap_text
  # 1 => load saved chap_text then convert
  # 2 => fetch text from external hosts then convert

  def get_text(ubid : String, seed : String, sbid : String, scid : String, mode : Int32 = 0)
    chtext = ChapText.load(ubid, seed, sbid, scid, mode: 1)
    cached = File.exists?(chtext.file)

    if remote?(seed) && (mode == 2 || !cached)
      source = SeedText.init(seed, sbid, scid, freeze: false)
      zh_data = [source.title].concat(source.paras)
      chtext.tap(&.zh_data = zh_data).save!
    elsif cached
      return chtext if mode == 0 && recent?(chtext.cv_time, 2.hours)
      zh_data = chtext.zh_data
    else
      zh_data = [
        "Lỗi: Chương tiết không có nội dung!",
        "Xin liên hệ với ban quản trị để khắc phục.",
      ]
    end

    chtext.tap do |x|
      x.cv_text = Libcv.cv_mixed(zh_data, ubid).map(&.to_s).join("\n")
      x.cv_time = Time.utc.to_unix_ms
    end
  end

  SEEDS = {
    "hetushu", "rengshu", "xbiquge",
    "nofff", "paoshu8", "69shu",
    "zhwenpg", "5200", "biquge5200",
    "shubaow",
  }

  def remote?(seed : String)
    SEEDS.includes?(seed)
  end

  def recent?(mftime : Int64, span = 1.hours)
    mftime > (Time.utc - span).to_unix_ms
  end
end

# info = BookDB.load("akpwpjf3").not_nil!
# puts info.vi_title

# chaps = Kernel.load_list(info, info.cr_site_df, refresh: true)
# puts chaps.reverse.first(4)

# paras = Kernel.load_chap(info, info.cr_site_df, "3183122")
# puts paras.first(10).map(&.vi_text)
