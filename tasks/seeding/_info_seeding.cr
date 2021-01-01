require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/shared/*"
require "../../src/filedb/nvinfo"
require "../../src/filedb/nvseed"

class CV::InfoSeeding
  getter name : String
  getter rdir : String

  getter _index : ValueMap { ValueMap.new(map_path("_index")) }

  getter bgenre : ValueMap { ValueMap.new(map_path("bgenre")) }
  getter bcover : ValueMap { ValueMap.new(map_path("bcover")) }

  getter status : ValueMap { ValueMap.new(map_path("status")) }
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
    puts "- [#{@name}/#{sbid}] book intro saved!".colorize.yellow
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

  def get_labels(sbid : String)
    btitle, author = _index.get(sbid).not_nil!
    {Butils.fix_zh_btitle(btitle), Butils.fix_zh_author(author)}
  end

  # def upsert_nvinfo!(sbid : String) : Nvinfo
  #   btitle, author = get_labels(sbid)
  #   nvinfo = Nvinfo.upsert!(btitle, author)

  #   nvinfo.set_intro(get_intro(sbid), @name) unless nvinfo.zh_intro

  #   bgenre = genres.get_value(sbid).not_nil!
  #   nvinfo.set_bgenre(bgenre)

  #   nvinfo.set_status(get_status(sbid))

  #   mftime = get_update(sbid)
  #   nvinfo.set_update_tz(mftime)
  #   nvinfo.set_access_tz(mftime // 300)

  #   yield nvinfo
  #   nvinfo.save!
  # end

  # def upsert_nvseed!(sbid : String, zh_slug : Int32)
  #   chseed = Chseed.upsert!(@name, sbid, &.nvinfo_id = nvinfo_id)

  #   chseed.set_update_tz(get_update(sbid))
  #   chseed.set_access_tz(Time.utc.to_unix)

  #   chseed.save!
  # end

  def save!(mode : Symbol = :full)
    @_index.try(&.save!(mode: mode))

    @bgenre.try(&.save!(mode: mode))
    @bcover.try(&.save!(mode: mode))

    @status.try(&.save!(mode: mode))
    @rating.try(&.save!(mode: mode))

    @update_tz.try(&.save!(mode: mode))
    @access_tz.try(&.save!(mode: mode))
  end
end
