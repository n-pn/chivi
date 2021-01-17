require "file_utils"
require "../stores/*"

class CV::ChMeta
  getter seed : String
  getter rdir : String

  def initialize(@seed)
    @rdir = "_db/chdata/chinfos/#{@seed}"
    ::FileUtils.mkdir_p(@rdir) unless File.exists?(@rdir)
  end

  getter _index : ValueMap { ValueMap.new("#{@rdir}/_index.tsv") }

  getter access_tz : ValueMap { ValueMap.new("#{@rdir}/tz_access.tsv") }
  getter update_tz : ValueMap { ValueMap.new("#{@rdir}/tz_update.tsv") }

  getter last_chap : ValueMap { ValueMap.new("#{@rdir}/last_chap.tsv") }

  getter count_chap : ValueMap { ValueMap.new("#{@rdir}/count_chap.tsv") }
  getter count_file : ValueMap { ValueMap.new("#{@rdir}/count_file.tsv") }

  def save!(mode : Symbol = :full) : Nil
    @_index.try(&.save!(mode: mode))
    @last_chap.try(&.save!(mode: mode))

    @access_tz.try(&.save!(mode: mode))
    @update_tz.try(&.save!(mode: mode))

    @count_chap.try(&.save!(mode: mode))
    @count_file.try(&.save!(mode: mode))
  end

  CACHE = {} of String => self

  def self.load(seed) : self
    CACHE[seed] ||= new(seed)
  end

  def self.save!(mode : Symbol = :full) : Nil
    CACHE.each_value(&.save!(mode: mode))
  end
end
