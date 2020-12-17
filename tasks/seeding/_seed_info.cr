require "json"
require "myhtml"
require "colorize"
require "file_utils"

require "../../src/shared/file_utils"
require "../../src/shared/http_utils"
require "../../src/shared/seed_utils"

require "../../src/kernel/book_repo"

class Chivi::Seeds::SeedSerial
  getter name : String

  getter _index : ValueMap { ValueMap.new("#{@root}/_index.tsv") }

  getter atimes : ValueMap { ValueMap.new("#{@root}/atimes.tsv") }
  getter utimes : ValueMap { ValueMap.new("#{@root}/utimes.tsv") }

  getter authors : ValueMap { ValueMap.new("#{@root}/authors.tsv") }
  getter btitles : ValueMap { ValueMap.new("#{@root}/btitles.tsv") }
  getter bgenres : ValueMap { ValueMap.new("#{@root}/bgenres.tsv") }

  getter intros = {} of String => Array(String)
  getter covers : ValueMap { ValueMap.new("#{@root}/covers.tsv") }

  getter status : ValueMap { ValueMap.new("#{@root}/status.tsv") }
  getter rating : ValueMap { ValueMap.new("#{@root}/rating.tsv") }

  def initialize(@name)
    @root = "_db/_seeds/#{@name}"
    @intro_dir = "#{@root}/intros"
    ::FileUtils.mkdir_p(@intro_dir)
  end

  def get_intro(sbid : String)
    @intros[sbid] ||= begin
      intro_file = "#{@intro_dir}/#{sbid}.txt"
      File.read_lines(intro_file) if File.exists?(intro_file)
    end
  end

  def set_intro(sbid : String, intro : Array(String)) : Nil
    @intros[sbid] = intro
    File.write("#{@intro_dir}/#{sbid}.txt", intro.join("\n"))
  end

  def save!
    @_index.try(&.save!)

    @atimes.try(&.save!)
    @utimes.try(&.save!)

    @authors.try(&.save!)
    @btitles.try(&.save!)
    @bgenres.try(&.save!)

    @covers.try(&.save!)
    @status.try(&.save!)
    @rating.try(&.save!)
  end
end
