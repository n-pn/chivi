require "file_utils"

require "./kernel/*"

module Kernel
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

  def load_list(info : BookInfo, seed_name : String, reload = false) : Tuple(ChapList, Int64)?
    return unless seed_sbid = info.seed_sbids[seed_name]?

    chlist = ChapList.get_or_create(info.ubid, seed_name)
    expiry = Time.utc - (reload ? 10.minutes : gen_expiry(info.status))

    if ChapList.outdated?(info.ubid, seed_name, expiry)
      remote = SeedInfo.init(seed_name, seed_sbid, expiry: expiry, freeze: false)

      BookRepo.update_info(info, remote)
      info.save! if info.changed?

      ChapRepo.update_list(chlist, remote)
      chlist.save! if chlist.changed?
    end

    {chlist, info.seed_mftimes[seed_name]}
  end

  # # modes:
  # 0 => load saved chap_text
  # 1 => load saved chap_text then convert
  # 2 => fetch text from external hosts then convert

  def load_text(ubid : String, seed : String, sbid : String, scid : String, mode : Int32 = 2)
    chap = ChapText.new(ubid, seed, scid, preload: false)

    if chap.exists? && mode < 2
      chap.load!

      return chap if mode == 0
      zh_lines = chap.zh_lines
    else
      remote = SeedText.init(seed, sbid, scid, freeze: false)
      zh_lines = [remote.title].concat(remote.paras)
    end

    chap.data = Engine.cv_mixed(zh_lines, ubid).map(&.to_s).join("\n")
    chap.tap(&.save!)
  end
end

# info = BookRepo.load("akpwpjf3").not_nil!
# puts info.vi_title

# chaps = Kernel.load_list(info, info.cr_site_df, refresh: true)
# puts chaps.reverse.first(4)

# paras = Kernel.load_chap(info, info.cr_site_df, "3183122")
# puts paras.first(10).map(&.vi_text)
