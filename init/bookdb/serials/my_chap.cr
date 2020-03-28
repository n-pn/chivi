require "./my_util"
require "../../../src/models/vp_chap"

class MyChap < VpChap
  def initialize(inp : CrInfo::Chap, @idx, @site, @bsid)
    @csid = inp._id

    @zh_title = inp.title
    @vi_title = MyUtil.translate(inp.title, title: true)

    @url_slug = CvUtil.slugify(@vi_title)

    @zh_volume = inp.volume
    @vi_volume = MyUtil.translate(inp.volume, title: true)

    text_file = "data/txt-tmp/chtexts/#{@site}/#{@bsid}/#{@csid}.txt"
    if File.exists?(text_file)
      @created_at = File.info(text_file).modification_time.to_unix_ms
      @updated_at = @created_at
    end
  end
end
