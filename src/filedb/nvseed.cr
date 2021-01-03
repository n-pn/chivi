require "./stores/*"

module CV::Nvseed
  extend self

  class Seed
    getter name : String
    getter rdir : String

    def initialize(@name)
      @rdir = "_db/nvdata/nvseeds/#{@name}"
    end

    getter _index : ValueMap { ValueMap.new("#{@rdir}/_index.tsv") }

    getter access_tz : ValueMap { ValueMap.new("#{@rdir}/access_tz.tsv") }
    getter update_tz : ValueMap { ValueMap.new("#{@rdir}/update_tz.tsv") }

    getter last_chap : ValueMap { ValueMap.new("#{@rdir}/last_chap.tsv") }

    getter count_chap : ValueMap { ValueMap.new("#{@rdir}/count_chap.tsv") }
    getter count_file : ValueMap { ValueMap.new("#{@rdir}/count_file.tsv") }
  end

  class_getter seeds = {} of String => Seed

  def load(name) : Seed
    @@seeds[name] ||= Seed.new(name)
  end
end
