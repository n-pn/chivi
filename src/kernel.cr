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
    return unless seed = info.seeds[seed_name]?

    list = ChapList.get_or_create(info.ubid, seed_name)

    expiry = Time.utc - (reload ? 10.minutes : gen_expiry(info.status))

    if ChapList.outdated?(info.ubid, seed_name, expiry)
      remote = SeedInfo.init(seed_name, seed.sbid, expiry: expiry, freeze: false)

      BookRepo.update_info(info, remote)
      info.save! if info.changed?

      ChapRepo.update_list(list, remote)
      list.save! if list.changed?
    end

    {list, seed.mftime}
  end
end

# info = BookRepo.load("akpwpjf3").not_nil!
# puts info.vi_title

# chaps = Kernel.load_list(info, info.cr_site_df, refresh: true)
# puts chaps.reverse.first(4)

# paras = Kernel.load_chap(info, info.cr_site_df, "3183122")
# puts paras.first(10).map(&.vi_text)
