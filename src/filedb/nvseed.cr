require "./stores/*"
require "file_utils"

class CV::Nvseed
  getter name : String
  getter rdir : String

  def initialize(@name)
    @rdir = "_db/nvdata/chseeds/#{@name}"
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

  class_getter cache = {} of String => self

  def self.load(name) : self
    @@cache[name] ||= new(name)
  end

  def self.save!(mode : Symbol = :full) : Nil
    @@cache.each_value(&.save!(mode: mode))
  end
end
