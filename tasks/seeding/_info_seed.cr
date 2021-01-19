require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/shared/text_utils"
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
  getter shield : ValueMap { ValueMap.new(map_path("shield")) }
  getter status : ValueMap { ValueMap.new(map_path("status")) }

  def initialize(@name)
    @rdir = "_db/_seeds/#{@name}"
    @intro_dir = "#{@rdir}/intros"
    ::FileUtils.mkdir_p(@intro_dir)
  end

  def map_path(fname : String)
    "#{@rdir}/#{fname}.tsv"
  end

  def save!(mode : Symbol = :full)
    @_index.try(&.save!(mode: mode))
    @_atime.try(&.save!(mode: mode))
    @_mtime.try(&.save!(mode: mode))

    @bcover.try(&.save!(mode: mode))
    @genres.try(&.save!(mode: mode))

    @rating.try(&.save!(mode: mode))
    @status.try(&.save!(mode: mode))

    @shield.try(&.save!(mode: mode))
  end

  def set_intro(sbid : String, intro : Array(String)) : Nil
    File.write(intro_path(sbid), intro.join("\n"))
  end

  def get_intro(sbid : String) : Array(String)
    File.read_lines(intro_path(sbid))
  rescue err
    [] of String
  end

  def intro_path(sbid)
    "#{@intro_dir}/#{sbid}.txt"
  end

  def get_genres(sbid : String)
    zh_genres = genres.get(sbid) || [] of String
    zh_genres = zh_genres.map { |x| NvHelper.fix_zh_genre(x) }.flatten.uniq

    vi_genres = zh_genres.map { |x| NvHelper.fix_vi_genre(x) }.uniq
    vi_genres.reject!("Loại khác")
    vi_genres.empty? ? ["Loại khác"] : vi_genres
  end

  getter source : ChSource { ChSource.load(@name) }

  def upsert!(sbid : String) : Tuple(String, Bool)
    btitle, author = _index.get(sbid).not_nil!
    b_hash, existed = Nvinfo.upsert!(btitle, author)

    bintro = get_intro(sbid)
    NvValues.set_bintro(b_hash, bintro) unless bintro.empty?

    genres = get_genres(sbid)
    NvValues.set_bgenre(b_hash, genres) unless genres.empty?

    mftime = mtime.ival_64(sbid)
    NvValues.set_mtime(b_hash, mftime)
    NvValues.set_atime(b_hash, mftime // 60)

    NvValues.set_status(b_hash, status.ival(sbid, 0))

    if @name != "yousuu"
      NvValues.set_chseed(b_hash, @name, sbid)

      mftime = NvValues.mtime.ival_64(b_hash) if @name == "hetushu"

      source._index.add(b_hash, sbid)
      source._mtime.add(sbid, mftime)
      source._atime.add(sbid, atime.ival_64(sbid))

      upsert_chinfo!(sbid, b_hash, expiry: Time.unix(mftime))
    end

    {b_hash, existed}
  end

  def upsert_chinfo!(sbid : String, b_hash : String, expiry : Time) : Nil
    chinfo = Chinfo.new(@name, sbid)
    chinfo.fetch!(expiry: expiry)
    chinfo.trans!(dname: b_hash)

    chinfo.save!(mode: :full)
  end
end
