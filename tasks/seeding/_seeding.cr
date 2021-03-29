require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/utils/text_utils"
require "../../src/utils/file_utils"

require "../../src/appcv/nv_info"
require "../../src/appcv/ch_info"

class CV::Seeding
  def self.get_atime(file : String) : Int64?
    File.info?(file).try(&.modification_time.to_unix)
  end

  getter sname : String
  getter seeds_dir : String

  getter _index : ValueMap { ValueMap.new(map_path("_index")) }

  getter genres : ValueMap { ValueMap.new(map_path("genres")) }
  getter bcover : ValueMap { ValueMap.new(map_path("bcover")) }

  getter rating : ValueMap { ValueMap.new(map_path("rating")) }
  getter hidden : ValueMap { ValueMap.new(map_path("hidden")) }

  getter status : ValueMap { ValueMap.new(map_path("status")) }
  getter update : ValueMap { ValueMap.new(map_path("update")) }

  def initialize(@sname)
    @seeds_dir = "_db/_seeds/#{@sname}"
    @intro_dir = "#{@seeds_dir}/intros"

    ::FileUtils.mkdir_p(@intro_dir)
  end

  def map_path(fname : String)
    "#{@seeds_dir}/#{fname}.tsv"
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
    zh_names = genres.get(snvid) || [] of String

    zh_names = zh_names.map { |x| NvGenres.fix_zh_name(x) }.flatten.uniq
    vi_names = zh_names.map { |x| NvGenres.fix_vi_name(x) }.uniq

    vi_names.reject!("Loại khác")
    vi_names.empty? ? ["Loại khác"] : vi_names
  end

  def upsert!(snvid : String, fixed = false) : Tuple(String, String, String)
    access, btitle, author = _index.get(snvid).not_nil!
    bhash, btitle, author = NvInfo.upsert!(btitle, author, fixed: fixed)

    genres = get_genres(snvid)
    NvGenres.set!(bhash, genres) unless genres.empty?

    bintro = get_intro(snvid)
    NvBintro.set!(bhash, bintro, force: false) unless bintro.empty?

    NvFields.set_status!(bhash, status.ival(snvid))

    mftime = update.ival_64(snvid)
    NvOrders.set_update!(bhash, mftime)
    NvOrders.set_access!(bhash, mftime // 60)

    {bhash, btitle, author}
  end

  def upsert_chinfo!(bhash : String, snvid : String, mode = 0) : Nil
    chinfo = ChInfo.new(bhash, @sname, snvid)

    mtime, total = chinfo.fetch!(power: 4, mode: mode, valid: 10.years)
    chinfo.trans!(reset: false)

    mtime = update.ival_64(snvid) if @sname == "zhwenpg"
    NvInfo.new(bhash).set_chseed(@sname, snvid, mtime, total)
  end
end
