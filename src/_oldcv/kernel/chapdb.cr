require "json"
require "colorize"

require "./models/chap_list"
require "./models/chap_text"

require "./seeds/seed_info"
require "./seeds/seed_text"

module Oldcv::ChapDB
  extend self

  def update_list(chlist : ChapList, source : SeedInfo, dirty = true, force = false)
    chlist.sbid = source.sbid

    chlist.merge!(source.chapters, dirty: dirty)
    translate_list(chlist, force: force)
  end

  def translate_list(chlist : ChapList, force = false)
    chlist.tap do |x|
      x.update_each do |chap|
        chap.tap &.translate!(chlist.ubid, force: force)
      end
    end
  end

  # # modes:
  # # 2 => load saved chap_text
  # # 1 => load saved chap_text then convert
  # # 0 => fetch text from external hosts then convert

  # def load_text(host : String, bsid : String, csid : String, udic : String = "local", bdic = "tonghop", mode : Int32 = 2)
  #   chap = ChapText.new(host, bsid, csid, preload: false)

  #   if chap.exists? && mode > 0
  #     chap.load!

  #     return chap if mode > 1
  #     zh_lines = chap.zh_lines
  #   else
  #     zh_lines = SeedText.fetch!(host, bsid, csid, keep_html: false)
  #   end

  #   chap.data = Engine.cv_mixed(zh_lines, bdic, udic).map(&.to_s).join("\n")
  #   chap.save!
  # end
end
