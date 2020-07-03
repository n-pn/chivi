require "json"
require "colorize"
require "file_utils"

class MapLabel::Bulk
  SEP = "ǁ"

  getter file : String
  getter data = Hash(String, String).new
  delegate size, to: @data
  delegate each, to: @data

  def initialize(@file, preload : Bool = false)
    load!(@file) if preload && exists?
  end

  def exists?
    File.exists?(@file)
  end

  def load!(file : String = @file) : Void
    File.each_line(file) do |line|
      key, val = line.split(SEP, 2)
      if val.blank?
        @data.delete(key)
      else
        @data[key] = val
      end
    rescue err
      puts "- <map_label> error parsing line `#{line}`: #{err.colorize(:red)}"
    end

    puts "- <map_label> [#{file.colorize(:cyan)}] loaded."
  end

  def save!(file : String = @file) : Void
    File.write(file, self)
    puts "- <map_label> [#{file.colorize(:cyan)}] saved, (entries: #{size})."
  end

  def includes?(key : String)
    @data.has_key?(key)
  end

  def get_val(key : String)
    @data[key]?
  end

  def upsert!(key : String, val : String) : Void
    return if @data[key]?.try(&.== val)

    File.open(@file, "a") { |io| io << key << SEP << val << "\n" }
    @data[key] = val
  end

  def delete!(key : String) : Void
    File.open(@file, "a") { |io| io << key << SEP << "\n" }
    @data.delete(key)
  end

  def to_s(io : IO)
    @data.each { |key, val| io << key << SEP << val << "\n" }
  end

  def to_s
    String.build { |io| to_s(io) }
  end
end

module MapLabel
  extend self

  DIR = File.join("var", "appcv", "map_labels")
  FileUtils.mkdir_p(DIR)

  def path_for(name : String)
    File.join(DIR, "#{name}.txt")
  end

  CACHE = {} of String => Bulk

  def load!(name : String) : Bulk
    CACHE[name] ||= init!(name)
  end

  def init!(name : String) : Bulk
    Bulk.new(path_for(name), preload: true)
  end

  def save!(bulk : Bulk, file : String = bulk.file) : Void
    bulk.save!(file)
  end
end
