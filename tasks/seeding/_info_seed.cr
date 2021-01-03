require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/shared/*"
require "../../src/filedb/nvinfo"
require "../../src/filedb/nvseed"

class CV::InfoSeed
  getter name : String
  getter rdir : String

  getter _index : ValueMap { ValueMap.new(map_path("_index")) }

  getter bgenre : ValueMap { ValueMap.new(map_path("bgenre")) }
  getter bcover : ValueMap { ValueMap.new(map_path("bcover")) }

  getter status : ValueMap { ValueMap.new(map_path("status")) }
  getter shield : ValueMap { ValueMap.new(map_path("shield")) }
  getter rating : ValueMap { ValueMap.new(map_path("rating")) }

  getter access_tz : ValueMap { ValueMap.new(map_path("tz_access")) }
  getter update_tz : ValueMap { ValueMap.new(map_path("tz_update")) }

  def map_path(fname : String)
    "#{@rdir}/#{fname}.tsv"
  end

  def initialize(@name)
    @rdir = "_db/_seeds/#{@name}"
    @intro_dir = "#{@rdir}/intros"
    ::FileUtils.mkdir_p(@intro_dir)
  end

  def set_intro(sbid : String, intro : Array(String)) : Nil
    File.write(intro_path(sbid), intro.join("\n"))
  end

  def get_intro(sbid : String) : Array(String)
    File.read_lines(intro_path(sbid))
  rescue
    [] of String
  end

  def intro_path(sbid)
    "#{@intro_dir}/#{sbid}.txt"
  end

  def get_status(sbid : String)
    status.fval(sbid).try(&.to_i?) || 0
  end

  def get_update_tz(sbid : String)
    update_tz.fval(sbid).try(&.to_i64?) || 0_i64
  end

  def get_access_tz(sbid : String)
    access_tz.fval(sbid).try(&.to_i64?) || 0_i64
  end

  def save!(mode : Symbol = :full)
    @_index.try(&.save!(mode: mode))

    @bgenre.try(&.save!(mode: mode))
    @bcover.try(&.save!(mode: mode))

    @status.try(&.save!(mode: mode))
    @rating.try(&.save!(mode: mode))

    @update_tz.try(&.save!(mode: mode))
    @access_tz.try(&.save!(mode: mode))
  end

  def upsert!(sbid : String, force : Bool = false) : Tuple(String, Bool)
    btitle, author = _index.get(sbid).not_nil!
    zh_slug, existed = Nvinfo.upsert!(btitle, author)

    bintro = get_intro(sbid)
    Nvinfo.set_bintro(zh_slug, bintro, force: force) unless bintro.empty?

    genres = get_genres(sbid)
    Nvinfo.set_bgenre(zh_slug, genres) unless genres.empty?

    mftime = get_update_tz(sbid)
    Nvinfo.set_update_tz(zh_slug, mftime)
    Nvinfo.set_access_tz(zh_slug, mftime)

    Nvinfo.set_status(zh_slug, status.ival(sbid, 0))
    Nvinfo.set_chseed(zh_slug, @name, sbid) unless @name == "yousuu"

    {zh_slug, existed}
  end

  def get_genres(sbid : String)
    zh_genres = bgenre.get(sbid) || [] of String
    zh_genres = zh_genres.map { |x| Nvinfo::Utils.fix_zh_genre(x) }.flatten.uniq

    vi_genres = zh_genres.map { |x| Nvinfo::Utils.fix_vi_genre(x) }.uniq
    vi_genres.reject!("Loại khác")

    vi_genres.empty? ? ["Loại khác"] : vi_genres
  end
end
