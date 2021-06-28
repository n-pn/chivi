require "colorize"
require "file_utils"

require "./seed_util"

class CV::SeedData
  getter sname : String
  getter s_dir : String

  getter _index : ValueMap { SeedUtil.load_map("#{@sname}/_index") }

  getter genres : ValueMap { SeedUtil.load_map("#{@sname}/genres") }
  getter bcover : ValueMap { SeedUtil.load_map("#{@sname}/bcover") }

  getter status : ValueMap { SeedUtil.load_map("#{@sname}/status") }
  getter mftime : ValueMap { SeedUtil.load_map("#{@sname}/mftime") }

  @intros = {} of String => ValueMap

  def initialize(@sname)
    @s_dir = "_db/zhseed/#{@sname}"
    ::FileUtils.mkdir_p("#{@s_dir}/intros")
  end

  private def intro_map(snvid : String)
    group = snvid.rjust(6, '0')[0, 3]
    @intros[group] ||= ValueMap.new("#{@s_dir}/intros/#{group}.tsv")
  end

  def set_intro(snvid : String, intro : Array(String)) : Nil
    intro_map(snvid).set!(snvid, intro)
  end

  def get_intro(snvid : String) : Array(String)
    intro_map(snvid).get(snvid) || [] of String
  end

  # def get_genres(snvid : String)
  #   zh_names = genres.get(snvid) || [] of String

  #   zh_names = zh_names.map { |x| NvGenres.fix_zh_name(x) }.flatten.uniq
  #   vi_names = zh_names.map { |x| NvGenres.fix_vi_name(x) }.uniq

  #   vi_names.reject!("Loại khác")
  #   vi_names.empty? ? ["Loại khác"] : vi_names
  # end

  def get_scores(snvid : String) : Array(Int32)
    bname = begin
      _, btitle, author = self._index.get(snvid).not_nil!
      "#{btitle}  #{author}"
    end

    if score = SeedUtil.rating_fix.get(bname)
      score.map(&.to_i)
    elsif @sname == "hetushu" || @sname == "zxcs_me"
      [Random.rand(30..100), Random.rand(50..65)]
    else
      [Random.rand(25..50), Random.rand(40..50)]
    end
  end

  def save!(clean : Bool = false)
    SeedUtil.save_maps!

    @_index.try(&.save!(clean: clean))

    @bcover.try(&.save!(clean: clean))
    @genres.try(&.save!(clean: clean))
    @intros.each_value(&.save!(clean: clean))

    @status.try(&.save!(clean: clean))
    @mftime.try(&.save!(clean: clean))
    @mftime.try(&.save!(clean: clean))
  end

  # def upsert!(snvid : String, fixed = false) : Tuple(String, String, String)
  #   _, btitle, author = _index.get(snvid).not_nil!
  #   bhash, btitle, author = NvInfo.upsert!(btitle, author, fixed: fixed)

  #   genres = get_genres(snvid)
  #   NvGenres.set!(bhash, genres) unless genres.empty?

  #   bintro = get_intro(snvid)
  #   NvBintro.set!(bhash, bintro, force: false) unless bintro.empty?

  #   NvFields.set_status!(bhash, get_status(snvid))

  #   mftime = update.ival_64(snvid)
  #   NvOrders.set_update!(bhash, mftime)
  #   NvOrders.set_access!(bhash, mftime // 60)

  #   {bhash, btitle, author}
  # end

  # def upsert_chinfo!(bhash : String, snvid : String, mode = 0) : Nil
  #   chinfo = ChInfo.new(bhash, @sname, snvid)

  #   mtime, total = chinfo.fetch!(power: 4, mode: mode, valid: 10.years)
  #   chinfo.trans!(reset: false) if chinfo.updated?

  #   mtime = update.ival_64(snvid) if @sname == "zhwenpg"
  #   NvInfo.new(bhash).set_chseed(@sname, snvid, mtime, total)
  # end
end
