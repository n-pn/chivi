require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/_utils/text_utils"
require "../../src/_utils/file_utils"

require "../../src/filedb/nvinfo"
require "../../src/filedb/chinfo"

class CV::InfoSeed
  class_getter author_scores : ValueMap { "_db/_seeds/author_scores.tsv" }

  def self.qualified_author?(author : String, minimum_score = 2000)
    return false unless score = author_scores.ival(author)
    # score 2000 mean 20 people give score 10 or 40 people give score 5
    score >= minimum_score
  end

  def self.update_author_score(author : String, score : Int32)
    if value = author_scores.ival(author)
      return if value > score
    end

    author_scores.set!(author, [score.to_s])
  end

  getter name : String
  getter rdir : String

  getter _index : ValueMap { ValueMap.new(map_path("_index")) }

  getter bcover : ValueMap { ValueMap.new(map_path("bcover")) }
  getter genres : ValueMap { ValueMap.new(map_path("genres")) }

  getter rating : ValueMap { ValueMap.new(map_path("rating")) }
  getter hidden : ValueMap { ValueMap.new(map_path("hidden")) }

  getter status : ValueMap { ValueMap.new(map_path("status")) }
  getter update : ValueMap { ValueMap.new(map_path("update")) }

  def initialize(@name)
    @rdir = "_db/_seeds/#{@name}"
    @intro_dir = "#{@rdir}/intros"
    ::FileUtils.mkdir_p(@intro_dir)

    # if @name != "yousuu"
    #   ::FileUtils.mkdir_p("_db/chdata/chinfos/#{@name}/origs")
    #   ::FileUtils.mkdir_p("_db/chdata/chinfos/#{@name}/infos")
    #   ::FileUtils.mkdir_p("_db/chdata/chinfos/#{@name}/stats")
    # end
  end

  def map_path(fname : String)
    "#{@rdir}/#{fname}.tsv"
  end

  def save!(clean : Bool = false)
    @_index.try(&.save!(clean: clean))

    @bcover.try(&.save!(clean: clean))
    @genres.try(&.save!(clean: clean))

    @status.try(&.save!(clean: clean))
    @hidden.try(&.save!(clean: clean))

    @rating.try(&.save!(clean: clean))
    @update.try(&.save!(clean: clean))
  end

  def set_intro(snvid : String, intro : Array(String)) : Nil
    File.write(intro_path(snvid), intro.join("\n"))
  end

  def get_intro(snvid : String) : Array(String)
    File.read_lines(intro_path(snvid))
  rescue err
    [] of String
  end

  def intro_path(snvid : String)
    "#{@intro_dir}/#{snvid}.txt"
  end

  def get_genres(snvid : String)
    zh_genres = genres.get(snvid) || [] of String
    zh_genres = zh_genres.map { |x| NvHelper.fix_zh_genre(x) }.flatten.uniq

    vi_genres = zh_genres.map { |x| NvHelper.fix_vi_genre(x) }.uniq
    vi_genres.reject!("Loại khác")
    vi_genres.empty? ? ["Loại khác"] : vi_genres
  end

  def set!(snvid : String, mode = 0) : Tuple(String, Bool)
    btitle, author = _index.get(snvid).not_nil!
    bhash, existed = Nvinfo.set!(btitle, author)

    genres = get_genres(snvid)
    Nvinfo.set_genres(bhash, genres) unless genres.empty?

    bintro = get_intro(snvid)
    NvBintro.set_bintro(bhash, bintro) unless bintro.empty?

    mtime = _utime.ival_64(snvid)
    NvValues.set_atime(bhash, mtime // 60)
    NvValues.set_utime(bhash, mtime)

    NvValues.set_status(bhash, status.ival(snvid, 0))

    if @name != "yousuu"
      chseed = NvChseed.get_chseed(bhash)

      NvChseed.put_chseed(@name, bhash, snvid)

      upsert_chinfo!(snvid, bhash, mode: mode)
    end

    {bhash, existed}
  end

  def upsert_chinfo!(snvid : String, bhash : String, mode = 0) : Nil
    chinfo = Chinfo.new(bhash, @name, snvid)

    mtime, total = chinfo.fetch!(force: mode > 1, valid: 1.years)
    Nvinfo.load(bhash).put_chseed!(@name, snvid, mtime, total)

    chinfo.trans!(force: mode > 1)
  end
end
