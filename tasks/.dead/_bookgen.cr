require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/cutil/text_utils"
require "../../src/cutil/file_utils"

require "../../src/appcv/nv_info"
require "../../src/appcv/ch_info"

module CV::Bookgen
  extend self

  def get_atime(file : String) : Int64?
    get_mtime(file + ".gz") || get_mtime(file)
  end

  def get_mtime(file : String)
    File.info?(file).try(&.modification_time.to_unix)
  end

  class_getter rating_fix : TsvStore { TsvStore.new("_db/_seeds/rating_fix.tsv", 2) }
  class_getter status_map : TsvStore { TsvStore.new("_db/_seeds/status_map.tsv", 2) }

  def get_scores(btitle : String, author : String, min = 40, max = 60)
    label = "#{btitle}  #{author}"
    score = rating_fix.get(label) || {Random.rand(30..100), Random.rand(min..max)}

    {score[0].to_i, score[1].to_i}
  end

  PROMPT = !ARGV.includes?("-no-prompt")

  def map_status(status : String)
    return 0 if status.empty?
    return status.to_i if status == "0" || status == "1" # for hetushu or zhwenpg

    unless val = status_map.get(status).try(&.first)
      if PROMPT
        print " - status int for <#{status}>: "

        if val = gets
          status_map.set!(status, val)
        end
      end
    end

    (val || "0").to_i? || 0
  end

  def save!(clean : Bool = false)
    @@rating_fix.try(&.save!(clean: clean))
    @@status_map.try(&.save!(clean: clean))
  end

  class Seed
    getter sname : String
    getter s_dir : String

    getter _index : TsvStore { TsvStore.new("#{@s_dir}/_index.tsv") }

    getter genres : TsvStore { TsvStore.new("#{@s_dir}/genres.tsv") }
    getter bcover : TsvStore { TsvStore.new("#{@s_dir}/bcover.tsv") }

    getter rating : TsvStore { TsvStore.new("#{@s_dir}/rating.tsv") }
    getter hidden : TsvStore { TsvStore.new("#{@s_dir}/hidden.tsv") }

    getter status : TsvStore { TsvStore.new("#{@s_dir}/status.tsv") }
    getter update : TsvStore { TsvStore.new("#{@s_dir}/update.tsv") }

    INTROS = {} of String => TsvStore

    def initialize(@sname)
      @s_dir = "_db/_seeds/#{@sname}"
      ::FileUtils.mkdir_p("#{@s_dir}/intros")
    end

    def save!(clean : Bool = false)
      @_index.try(&.save!(clean: clean))

      @bcover.try(&.save!(clean: clean))
      @genres.try(&.save!(clean: clean))

      @status.try(&.save!(clean: clean))
      @hidden.try(&.save!(clean: clean))

      @rating.try(&.save!(clean: clean))
      @update.try(&.save!(clean: clean))

      INTROS.each_value(&.save!(clean: clean))
    end

    def upsert!(snvid : String, fixed = false) : Tuple(String, String, String)
      _, btitle, author = _index.get(snvid).not_nil!
      bhash, btitle, author = NvInfo.upsert!(btitle, author, fixed: fixed)

      genres = get_genres(snvid)
      NvGenres.set!(bhash, genres) unless genres.empty?

      bintro = get_intro(snvid)
      NvBintro.set!(bhash, bintro, force: false) unless bintro.empty?

      NvFields.set_status!(bhash, get_status(snvid))

      mftime = update.ival_64(snvid)
      NvOrders.set_update!(bhash, mftime)
      NvOrders.set_access!(bhash, mftime // 60)

      {bhash, btitle, author}
    end

    def upsert_chinfo!(bhash : String, snvid : String, mode = 0) : Nil
      chinfo = ChInfo.new(bhash, @sname, snvid)

      mtime, total = chinfo.fetch!(power: 4, mode: mode, valid: 10.years)
      chinfo.trans!(reset: false) if chinfo.updated?

      mtime = update.ival_64(snvid) if @sname == "zhwenpg"
      NvInfo.new(bhash).set_chseed(@sname, snvid, mtime, total)
    end

    def get_status(snvid : String) : Int32
      return 1 if @sname == "zxcs_me"

      status_str = status.fval(snvid) || "N/A"

      case @sname
      when "zhwenpg", "hetushu", "yousuu", "69shu"
        status_str.to_i
      else
        Bookgen.map_status(status_str)
      end
    end

    def intro_map(snvid : String)
      group = snvid.rjust(6, '0')[0, 3]
      INTROS[group] ||= TsvStore.new("#{@s_dir}/intros/#{group}.tsv")
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
  end
end
