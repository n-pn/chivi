require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/shared/file_utils"
require "../../src/shared/http_utils"
require "../../src/shared/seed_utils"

require "../../src/kernel"

class Chivi::InfoSeeding
  getter name : String
  getter rdir : String

  getter _index : ValueMap { ValueMap.new(map_path("_index")) }

  getter genres : ValueMap { ValueMap.new(map_path("genres")) }
  getter covers : ValueMap { ValueMap.new(map_path("covers")) }

  getter update : ValueMap { ValueMap.new(map_path("update")) }
  getter access : ValueMap { ValueMap.new(map_path("access")) }

  getter status : ValueMap { ValueMap.new(map_path("status")) }
  getter rating : ValueMap { ValueMap.new(map_path("rating")) }

  getter intro_cache = {} of String => Array(String)
  getter chaps_cache = {} of String => Array(String)

  def map_path(fname : String)
    "#{@rdir}/#{fname}.tsv"
  end

  def initialize(@name)
    @rdir = "_db/_seeds/#{@name}"
    @intros_dir = "#{@rdir}/intros"
    @chlist_dir = "#{@rdir}/chlist"

    ::FileUtils.mkdir_p(@intros_dir)
    ::FileUtils.mkdir_p(@chlist_dir)
  end

  def get_intro(sbid : String) : Array(String)
    @intro_cache[sbid] ||= begin
      File.read_lines(intro_path(sbid))
    rescue
      [] of String
    end
  end

  def set_intro(sbid : String, intro : Array(String)) : Nil
    puts "- [#{@name}/#{sbid}] book intro saved!".colorize.yellow
    File.write(intro_path(sbid), intro.join("\n"))
    @intro_cache[sbid] = intro
  end

  def intro_path(sbid)
    "#{@intros_dir}/#{sbid}.txt"
  end

  def get_chaps(sbid : String)
    @chaps_cache[sbid] ||= begin
      File.read_lines(chaps_path(sbid))
    rescue
      [] of String
    end
  end

  def set_chaps(sbid : String, chaps : Array(String)) : Nil
    puts "- [#{@name}/#{sbid}] chapter list saved!".colorize.yellow
    File.write(chaps_path(sbid), chaps.join("\n"))
    @chaps_cache[sbid] = chaps
  end

  def has_chaps?(sbid : String)
    File.exists?(chaps_path(sbid))
  end

  def chaps_path(sbid)
    "#{@chlist_dir}/#{sbid}.tsv"
  end

  def get_status(sbid : String)
    status.get_value(sbid).try(&.to_i?) || 0
  end

  def get_update(sbid : String)
    update.get_value(sbid).try(&.to_i64?) || 0_i64
  end

  def get_bname(sbid : String)
    btitle, author = _index.get_value(sbid).not_nil!.split("  ", 2)
    {Btitle.fix_zh_name(btitle), Author.fix_zh_name(author)}
  end

  def upsert_nvinfo!(sbid : String) : Nvinfo
    btitle, author = get_bname(sbid)
    nvinfo = Nvinfo.upsert!(btitle, author)

    nvinfo.set_intro(get_intro(sbid), @name) unless nvinfo.zh_intro

    bgenre = genres.get_value(sbid).not_nil!
    nvinfo.set_bgenre(bgenre)

    nvinfo.set_status(get_status(sbid))

    mftime = get_update(sbid)
    nvinfo.set_update_tz(mftime)
    nvinfo.set_access_tz(mftime // 300)

    yield nvinfo
    nvinfo.save!
  end

  def upsert_chseed!(sbid : String, nvinfo_id : Int32)
    chseed = Chseed.upsert!(@name, sbid, &.nvinfo_id = nvinfo_id)

    chseed.set_update_tz(get_update(sbid))
    chseed.set_access_tz(Time.utc.to_unix)

    chseed.save!
  end

  def save!
    @_index.try(&.save!)

    @genres.try(&.save!)
    @covers.try(&.save!)

    @update.try(&.save!)
    @access.try(&.save!)

    @status.try(&.save!)
    @rating.try(&.save!)
  end
end
