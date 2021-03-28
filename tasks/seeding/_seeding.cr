require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/utils/text_utils"
require "../../src/utils/file_utils"

require "../../src/appcv/nvinfo"
require "../../src/appcv/chinfo"

class CV::InfoSeed
  class_getter author_scores : ValueMap do
    ValueMap.new("_db/_seeds/author_scores.tsv")
  end

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
    ::FileUtils.mkdir_p("_db/chdata/zhinfos/#{@sname}") if @sname != "yousuu"
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
    zh_genres = genres.get(snvid) || [] of String
    zh_genres = zh_genres.map { |x| NvUtils.fix_genre_zh(x) }.flatten.uniq

    vi_genres = zh_genres.map { |x| NvUtils.fix_genre_vi(x) }.uniq
    vi_genres.reject!("Loại khác")
    vi_genres.empty? ? ["Loại khác"] : vi_genres
  end

  def upsert!(snvid : String) : Tuple(Nvinfo, Bool)
    access, btitle, author = _index.get(snvid).not_nil!
    nvinfo, existed = Nvinfo.upsert!(btitle, author, fixed: false)

    genres = get_genres(snvid)
    nvinfo.set_genres(genres) unless genres.empty?

    bintro = get_intro(snvid)
    nvinfo.set_bintro(bintro, force: false) unless bintro.empty?

    nvinfo.set_status(status.ival(snvid))

    mftime = update.ival_64(snvid)
    nvinfo.set_update(mftime)
    nvinfo.bump_access!(mftime)

    {nvinfo, existed}
  end

  def upsert_chinfo!(nvinfo : Nvinfo, snvid : String, mode = 0) : Nil
    chinfo = Chinfo.new(nvinfo.bhash, @sname, snvid)
    mtime, total = chinfo.fetch!(mode: mode, valid: 2.years)
    nvinfo.set_chseed(@sname, snvid, mtime, total)
  end
end
