require "../../engine"
require "../../bookdb/chap_info"

module ChapRepo::Utils
  extend self

  def convert(chap : ChapInfo, ubid : String, force = false)
    if force || chap.zh_label.empty?
      chap.vi_label = cv_title(chap.zh_label, ubid)
    end

    if force || chap.zh_title.empty?
      chap.vi_title = cv_title(chap.zh_title, ubid)
      chap.set_slug(chap.vi_title)
    end

    chap
  end

  def cv_title(input : String, dname : String)
    return input if input.empty?
    Engine.cv_title(input, dname).vi_text
  end
end
