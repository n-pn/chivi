require "json"
require "colorize"

require "./models/chap_text"
require "./models/chap_tran"

require "./import/source_text"
require "../engine"

module ChapRepo
  extend self

  # modes:
  # 2 => load saved chap_tran
  # 1 => load saved chap_text then convert to chap_tran
  # 0 => fetch text from external hosts then convert to chap_tran

  def load_tran(host : String, bsid : String, csid : String, user : String = "local", dict = "tonghop", mode : Int32 = 2)
    tran = ChapTran.new(host, bsid, csid, user, preload: false)
    return tran.load! if mode > 1 && tran.cached?

    text = load_text(host, bsid, csid, mode)
    tran.lines.clear

    Engine.cv_mixed(text.lines, dict, user).each do |nodes|
      tran.lines << node.to_s
    end

    tran.save!
  end

  # modes:
  # 1 => load saved chap_text
  # 0 => fetch text from external hosts

  def load_text(host : String, bsid : String, csid : String, mode : Int32 = 1)
    text = ChapText.new(host, bsid, csid)

    if mode > 0 && text.cached?
      text.load!
    else
      text.lines = SourceText.fetch!(host, bsid, csid, keep_html: false)
      text.save!
    end
  end
end
