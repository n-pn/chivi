require "file_utils"

require "../../mapper/*"

class CV::ChSource
  getter sname : String
  getter ch_dir : String

  def initialize(@sname)
    @ch_dir = "_db/chdata/chinfos/#{@sname}"
    ::FileUtils.mkdir_p(@ch_dir) unless File.exists?(@ch_dir)
  end

  getter _index : ValueMap { ValueMap.new("#{@ch_dir}/_index.tsv") }

  getter _utime : ValueMap { ValueMap.new("#{@ch_dir}/_utime.tsv") }

  getter lastch : ValueMap { ValueMap.new("#{@ch_dir}/l_chid.tsv") }

  getter chap_count : ValueMap { ValueMap.new("#{@ch_dir}/chap_count.tsv") }
  getter text_count : ValueMap { ValueMap.new("#{@ch_dir}/text_count.tsv") }

  def save!(mode : Symbol = :full) : Nil
    @_index.try(&.save!(mode: mode))
    @_utime.try(&.save!(mode: mode))
    @lastch.try(&.save!(mode: mode))

    @chap_count.try(&.save!(mode: mode))
    @text_count.try(&.save!(mode: mode))
  end

  def get_lastch(snvid : String) : String
    lastch.fval(snvid) || ""
  end

  def set_lastch(snvid : String, schid : String) : Bool
    lastch.add(snvid, schid)
  end

  def get_utime(snvid : String) : Int64
    _utime.ival_64(snvid)
  end

  def set_utime(snvid : String, mtime : Int64, force : Bool = false) : Bool
    return false unless force || mtime > get_utime(snvid)
    _utime.add(snvid, mtime)
  end

  CACHE = {} of String => self

  def self.load(sname : String) : self
    CACHE[sname] ||= new(sname)
  end

  def self.save!(mode : Symbol = :full) : Nil
    CACHE.each_value(&.save!(mode: mode))
  end

  def self.get_utime(sname : String, snvid : String)
    load(sname).get_utime(snvid)
  end
end
