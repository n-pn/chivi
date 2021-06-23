require "colorize"
require "file_utils"

require "../../../src/tabkv/value_map"

class CV::SeedData
  class_getter rating_fix : ValueMap { ValueMap.new("_db/_seeds/rating_fix.tsv", 2) }
  class_getter status_map : ValueMap { ValueMap.new("_db/_seeds/status_map.tsv", 2) }

  getter zseed : String
  getter s_dir : String

  getter _index : ValueMap { load_map("_index") }

  getter genres : ValueMap { load_map("genres") }
  getter bcover : ValueMap { load_map("bcover") }

  getter rating : ValueMap { load_map("rating") }
  getter hidden : ValueMap { load_map("hidden") }

  getter status : ValueMap { load_map("status") }
  getter update : ValueMap { load_map("update") }

  # for yousuu only
  getter source_url : ValueMap { load_map("source_url") }
  getter count_word : ValueMap { load_map("count_word") }
  getter count_crit : ValueMap { load_map("count_crit") }
  getter count_list : ValueMap { load_map("count_list") }

  INTRO_MAPS = {} of String => ValueMap

  def initialize(@zseed)
    @s_dir = "_db/_seeds/#{@zseed}"
    ::FileUtils.mkdir_p("#{@s_dir}/intros")
  end

  def load_map(name : String)
    ValueMap.new("#{@s_dir}/#{name}.tsv")
  end

  def get_status(snvid : String) : Int32
    case @zseed
    when "zxcs_me"                      then 1
    when "zhwenpg", "hetushu", "yousuu" then self.status.ival(snvid)
    else
      return 0 unless status_str = self.status.fval(snvid)

      unless status_int = SeedData.status_map.fval(status_str)
        print " - status int for <#{status_str}>: "

        if status_int = gets.try(&.strip)
          SeedData.status_map.set!(status_str, status_int)
        end
      end

      status_int.try(&.to_i?) || 0
    end
  end

  def intro_map(snvid : String)
    group = snvid.rjust(6, '0')[0, 3]
    INTRO_MAPS[group] ||= ValueMap.new("#{@s_dir}/intros/#{group}.tsv")
  end

  def set_intro(snvid : String, intro : Array(String)) : Nil
    intro_map(snvid).set!(snvid, intro)
  end

  def get_intro(snvid : String) : Array(String)
    intro_map(snvid).get(snvid) || [] of String
  end

  def get_genres(snvid : String)
    zh_names = genres.get(snvid) || [] of String

    zh_names = zh_names.map { |x| NvGenres.fix_zh_name(x) }.flatten.uniq
    vi_names = zh_names.map { |x| NvGenres.fix_vi_name(x) }.uniq

    vi_names.reject!("Loại khác")
    vi_names.empty? ? ["Loại khác"] : vi_names
  end

  def get_scores(snvid : String) : Array(Int32)
    case @zseed
    when "yousuu"
      self.rating.get(snvid).not_nil!.map(&.to_i)
    else
      bname = begin
        _, btitle, author = self._index.get(snvid).not_nil!
        "#{btitle}  #{author}"
      end

      if score = SeedData.rating_fix.get(bname)
        score.map(&.to_i)
      elsif @zseed == "hetushu" || @zseed == "zxcs_me"
        [Random.rand(30..100), Random.rand(50..65)]
      else
        [Random.rand(25..50), Random.rand(40..50)]
      end
    end
  end

  def save!(clean : Bool = false)
    @@rating_fix.try(&.save!(clean: false))
    @@status_map.try(&.save!(clean: false))

    @_index.try(&.save!(clean: clean))

    @bcover.try(&.save!(clean: clean))
    @genres.try(&.save!(clean: clean))

    @status.try(&.save!(clean: clean))
    @hidden.try(&.save!(clean: clean))

    @rating.try(&.save!(clean: clean))
    @update.try(&.save!(clean: clean))

    @source_url.try(&.save!(clean: clean))
    @count_word.try(&.save!(clean: clean))
    @count_crit.try(&.save!(clean: clean))
    @count_list.try(&.save!(clean: clean))

    INTRO_MAPS.each_value(&.save!(clean: clean))
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
  #   chinfo = ChInfo.new(bhash, @zseed, snvid)

  #   mtime, total = chinfo.fetch!(power: 4, mode: mode, valid: 10.years)
  #   chinfo.trans!(reset: false) if chinfo.updated?

  #   mtime = update.ival_64(snvid) if @zseed == "zhwenpg"
  #   NvInfo.new(bhash).set_chseed(@zseed, snvid, mtime, total)
  # end
end
