require "file_utils"

require "../../mapper/*"

class CV::ChSource
  getter s_name : String
  getter ch_dir : String

  def initialize(@s_name)
    @ch_dir = "_db/chdata/chinfos/#{@s_name}"
    ::FileUtils.mkdir_p(@ch_dir) unless File.exists?(@ch_dir)
  end

  getter _index : ValueMap { ValueMap.new("#{@ch_dir}/_index.tsv") }

  getter _atime : ValueMap { ValueMap.new("#{@ch_dir}/_atime.tsv") }
  getter _utime : ValueMap { ValueMap.new("#{@ch_dir}/_utime.tsv") }

  getter l_chid : ValueMap { ValueMap.new("#{@ch_dir}/l_chid.tsv") }

  getter chap_count : ValueMap { ValueMap.new("#{@ch_dir}/chap_count.tsv") }
  getter text_count : ValueMap { ValueMap.new("#{@ch_dir}/text_count.tsv") }

  def save!(mode : Symbol = :full) : Nil
    @_index.try(&.save!(mode: mode))
    @_atime.try(&.save!(mode: mode))
    @_utime.try(&.save!(mode: mode))
    @l_chid.try(&.save!(mode: mode))

    @chap_count.try(&.save!(mode: mode))
    @text_count.try(&.save!(mode: mode))
  end

  CACHE = {} of String => self

  def self.load(s_name : String) : self
    CACHE[s_name] ||= new(s_name)
  end

  def self.save!(mode : Symbol = :full) : Nil
    CACHE.each_value(&.save!(mode: mode))
  end

  def self.utime(s_name : String, s_nvid : String)
    load(s_name)._utime.fval_64(s_nvid)
  end
end
