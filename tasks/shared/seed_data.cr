require "colorize"
require "./seed_util"

class CV::SeedData
  getter sname : String
  getter s_dir : String

  getter _index : ValueMap { SeedUtil.load_map("#{@sname}/_index") }

  @intros = {} of String => ValueMap
  getter genres : ValueMap { SeedUtil.load_map("#{@sname}/genres") }
  getter bcover : ValueMap { SeedUtil.load_map("#{@sname}/bcover") }

  getter status : ValueMap { SeedUtil.load_map("#{@sname}/status") }
  getter mftime : ValueMap { SeedUtil.load_map("#{@sname}/mftime") }

  getter scores : ValueMap { SeedUtil.load_map("#{@sname}/scores") }
  getter counts : ValueMap { SeedUtil.load_map("#{@sname}/counts") }

  getter chsize : ValueMap { SeedUtil.load_map("#{@sname}/chsize") }
  getter origin : ValueMap { SeedUtil.load_map("#{@sname}/origin") }

  def initialize(@sname)
    @s_dir = "_db/zhbook/#{@sname}"
    ::FileUtils.mkdir_p("#{@s_dir}/intros")
  end

  def get_index(snvid : String) : Tuple(Int64, String, String)
    return {0_i64, "", ""} unless value = self._index.get(snvid)
    {value[0].to_i64, value[1], value[2]}
  end

  def get_counts(snvid : String) : Array(Int32)
    self.counts.get(snvid).try(&.map(&.to_i)) || [0, 0, 0]
  end

  def get_status(snvid : String) : Array(Int32)
    self.status.get(snvid).try(&.map { |x| x.to_i? || 0 }) || [0, 0]
  end

  def get_mftime(snvid : String) : Int64
    self.mftime.ival_64(snvid)
  end

  private def intro_map(snvid : String) : ValueMap
    group = snvid.rjust(6, '0')[0, 3]
    @intros[group] ||= ValueMap.new("#{@s_dir}/intros/#{group}.tsv")
  end

  def get_genres(snvid : String) : Array(String)
    self.genres.get(snvid) || [] of String
  end

  def get_bcover(snvid : String) : String
    # TODO: generate book cover without have to load cover file
    @seed.bcover.fval(snvid) || ""
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
    if scores = self.scores.get(snvid)
      scores.map(&.to_i)
    elsif scores = SeedUtil.rating_fix.get(get_nlabel(snvid))
      scores.map(&.to_i)
    elsif @sname == "hetushu" || @sname == "zxcs_me"
      [Random.rand(30..100), Random.rand(50..65)]
    else
      [Random.rand(25..50), Random.rand(40..50)]
    end
  end

  private def get_nlabel(snvid : String)
    _, btitle, author = self._index.get(snvid).not_nil!
    "#{btitle}  #{author}"
  end

  def get_origin(snvid : String)
    self.origin.get(snvid) || ["", ""]
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

    @chsize.try(&.save!(clean: clean))
    @counts.try(&.save!(clean: clean))
    @origin.try(&.save!(clean: clean))
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
