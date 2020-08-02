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
    return unless seed_sbid = info.seed_sbids[seed]?

    chlist = ChapList.get_or_create(info.ubid, seed)
    expiry = mode > 0 ? (Time.utc - 5.minutes) : Time.unix_ms(info.mftime)

    if ChapList.outdated?(info.ubid, seed, expiry)
      remote = SeedInfo.init(seed, seed_sbid, expiry: expiry, freeze: false)

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

  def load_text(ubid : String, seed : String, sbid : String, scid : String, mode : Int32 = 0)
    chap = ChapText.new(ubid, seed, scid, preload: false)

    if chap.exists? && (mode < 2 || chap.type > 0)
      chap.load!

      return chap unless mode > 0 || chap.outdated?(1.hours)
      zh_lines = chap.zh_lines
    else
      remote = SeedText.init(seed, sbid, scid, freeze: false)
      zh_lines = [remote.title].concat(remote.paras)
    end

    chap.data = Libcv.cv_mixed(zh_lines, ubid).map(&.to_s).join("\n")
    chap.save!

    chap
  end
end

# info = BookDB.load("akpwpjf3").not_nil!
# puts info.vi_title

# chaps = Kernel.load_list(info, info.cr_site_df, refresh: true)
# puts chaps.reverse.first(4)

# paras = Kernel.load_chap(info, info.cr_site_df, "3183122")
# puts paras.first(10).map(&.vi_text)
