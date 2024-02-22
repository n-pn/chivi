# require "../../../wndata/models/zh_book"
require "../../../_util/book_util"
require "../../../_util/tran_util"

require "../../../_data/wnovel/wninfo"

class CV::WninfoForm
  include JSON::Serializable

  getter wn_id : Int32 = 0

  getter btitle_zh : String
  getter btitle_vi : String

  getter author_zh : String
  getter author_vi : String

  getter intro_zh : String
  getter intro_vi : String

  getter genres : Array(String)
  getter bcover : String = ""

  getter status : Int32 = 0

  getter origins : Array(String) = [] of String

  def after_initialize
    @author_zh = @author_zh.strip
    @btitle_zh = @btitle_zh.strip
    @author_zh, @btitle_zh = BookUtil.fix_names(author: @author_zh, btitle: @btitle_zh)

    @author_vi = @author_vi.strip
    @btitle_vi = @btitle_vi.strip
    raise "invalid" if @author_vi.empty? || @btitle_vi.empty?

    @intro_zh = @intro_zh.strip
    @intro_vi = @intro_vi.strip
    raise "invalid" if !@intro_zh.empty? && @intro_vi.empty?

    # gen_vi_data! unless @author_vi && @btitle_vi && @intro_vi
  end

  # record ViData, btitle : String, author : String, bintro : String do
  #   include JSON::Serializable

  #   def after_initialize
  #     @bintro = @bintro.strip
  #   end
  # end

  # def gen_vi_data!
  #   return unless wndata = TranUtil.tl_wndata(@btitle_zh, @author_zh, @intro_zh || "", wn_id: @wn_id)

  #   @author_vi ||= wndata.author
  #   @btitle_vi ||= wndata.btitle
  #   @intro_vi ||= wndata.bintro
  # end

  def save!(_uname : String, _privi : Int32) : Wninfo
    Author.upsert!(@author_zh, @author_vi)
    Btitle.upsert!(@btitle_zh, bt_vi: @btitle_vi)

    wninfo = Wninfo.upsert!(@author_zh, @btitle_zh, name_fixed: true)

    wninfo.author_vi = @author_vi
    wninfo.btitle_vi = @btitle_vi

    wninfo.zintro = @intro_zh
    wninfo.bintro = @intro_vi.split(/\R/).map(&.strip).join('\n')

    vi_genres = @genres.map!(&.strip).reject!(&.empty?)
    vi_genres = ["Loại khác"] if vi_genres.empty?

    # zh_genres = GenreMap.vi_to_zh(vi_genres)
    # @zh_user.genres = zh_genres.join("\t")
    # @zh_base.genres = zh_genres.join("\t")

    wninfo.vgenres = vi_genres
    wninfo.igenres = GenreMap.map_int(vi_genres)

    wninfo.set_bcover(@bcover, force: true)
    wninfo.set_status(@status, force: true)
    spawn wninfo.cache_cover(@bcover, persist: false)

    wninfo.tap(&.save!)
  end
end
