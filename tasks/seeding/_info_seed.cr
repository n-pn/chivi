require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/_utils/text_utils"
require "../../src/_utils/file_utils"

require "../../src/filedb/nvinfo"
require "../../src/filedb/chinfo"

class CV::InfoSeed
  getter name : String
  getter rdir : String

  getter _index : ValueMap { ValueMap.new(map_path("_index")) }
  getter _atime : ValueMap { ValueMap.new(map_path("_atime")) }
  getter _utime : ValueMap { ValueMap.new(map_path("_utime")) }

  getter bcover : ValueMap { ValueMap.new(map_path("bcover")) }
  getter genres : ValueMap { ValueMap.new(map_path("genres")) }

  getter rating : ValueMap { ValueMap.new(map_path("rating")) }
  getter status : ValueMap { ValueMap.new(map_path("status")) }
  getter hidden : ValueMap { ValueMap.new(map_path("hidden")) }

  def initialize(@name)
    @rdir = "_db/_seeds/#{@name}"
    @intro_dir = "#{@rdir}/intros"
    ::FileUtils.mkdir_p(@intro_dir)

    if @name != "yousuu"
      ::FileUtils.mkdir_p("_db/chdata/chinfos/#{@name}/origs")
      ::FileUtils.mkdir_p("_db/chdata/chinfos/#{@name}/infos")
      ::FileUtils.mkdir_p("_db/chdata/chinfos/#{@name}/stats")
    end
  end

  def map_path(fname : String)
    "#{@rdir}/#{fname}.tsv"
  end

  def save!(mode : Symbol = :full)
    @_index.try(&.save!(mode: mode))
    @_atime.try(&.save!(mode: mode))
    @_utime.try(&.save!(mode: mode))

    @bcover.try(&.save!(mode: mode))
    @genres.try(&.save!(mode: mode))

    @rating.try(&.save!(mode: mode))
    @status.try(&.save!(mode: mode))
    @hidden.try(&.save!(mode: mode))
  end

  def set_intro(s_nvid : String, intro : Array(String)) : Nil
    File.write(intro_path(s_nvid), intro.join("\n"))
  end

  def get_intro(s_nvid : String) : Array(String)
    File.read_lines(intro_path(s_nvid))
  rescue err
    [] of String
  end

  def intro_path(s_nvid : String)
    "#{@intro_dir}/#{s_nvid}.txt"
  end

  def get_genres(s_nvid : String)
    zh_genres = genres.get(s_nvid) || [] of String
    zh_genres = zh_genres.map { |x| NvHelper.fix_zh_genre(x) }.flatten.uniq

    vi_genres = zh_genres.map { |x| NvHelper.fix_vi_genre(x) }.uniq
    vi_genres.reject!("Loại khác")
    vi_genres.empty? ? ["Loại khác"] : vi_genres
  end

  getter source : ChSource { ChSource.load(@name) }

  def upsert!(s_nvid : String) : Tuple(String, Bool)
    btitle, author = _index.get(s_nvid).not_nil!
    b_hash, existed = Nvinfo.upsert!(btitle, author)

    genres = get_genres(s_nvid)
    Nvinfo.set_genres(b_hash, genres) unless genres.empty?

    bintro = get_intro(s_nvid)
    NvValues.set_bintro(b_hash, bintro) unless bintro.empty?

    mtime = _utime.ival_64(s_nvid)
    NvValues.set_atime(b_hash, mtime // 60)
    NvValues.set_utime(b_hash, mtime)

    NvValues.set_status(b_hash, status.ival(s_nvid, 0))

    if @name != "yousuu"
      Nvinfo.set_source(b_hash, @name, s_nvid)

      mtime = NvValues._utime.ival_64(b_hash) if @name == "hetushu"

      source._index.add(b_hash, s_nvid)
      source._utime.add(s_nvid, mtime)
      source._atime.add(s_nvid, _atime.ival_64(s_nvid))

      upsert_chinfo!(s_nvid, b_hash, expiry: Time.unix(mtime))
    end

    {b_hash, existed}
  end

  def upsert_chinfo!(s_nvid : String, b_hash : String, expiry : Time) : Nil
    expiry -= 1.months if @name == "hetushu"
    chinfo = Chinfo.new(@name, s_nvid)

    return false unless chinfo.fetch!(force: false, expiry: expiry)
    chinfo.trans!(dname: b_hash)

    chinfo.origs.save!(mode: :full)
    chinfo.infos.save!(mode: :full)
  end
end
