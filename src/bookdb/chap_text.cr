require "json"
require "colorize"

require "./models/zh_text"
require "./models/vp_text"

require "./import/source_text"

require "../engine"

module ChapText
  extend self

  # modes:
  # 2 => load saved vp_text
  # 1 => load saved zh_text then convert vp_text
  # 0 => fetch text from external sites then convert to vp_text

  def load_vp(site : String, bsid : String, csid : String, user : String = "local", dict = "tonghop", mode : Int32 = 2)
    vp_text = VpText.new(site, bsid, csid, user)
    return vp_text.load! if mode > 1 && vp_text.cached?

    zh_text = load_zh(site, bsid, csid, mode)
    vp_text.lines.clear

    Engine.cv_mixed(zh_text.lines, dict, user).each do |nodes|
      vt_text.lines << node.to_s
    end

    vp_text.save!
  end

  # modes:
  # 1 => load saved zh_text
  # 0 => fetch text from external sites

  def load_zh(site : String, bsid : String, csid : String, mode : Int32 = 1)
    zh_text = ZhText.new(site, bsid, csid)

    if mode > 0 && zh_text.cached?
      zh_text.load!
    else
      zh_text.lines = SourceText.fetch!(site, bsid, csid, keep_html: false)
      zh_text.save!
    end
  end
end
