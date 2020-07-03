require "colorize"
require "file_utils"
require "./chap_item"

class ChapSeed
  getter seed : String
  getter sbid : String
  getter file : String

  getter data = [] of ChapItem
  forward_missing_to @data

  def initialize(@seed : String, @sbid : String, preload : Bool = false)
    @file = File.join(DIR, "#{@seed}.#{@sbid}.json")

    load!(@file) if preload && exists?
  end

  def exists?
    File.exists?(@file)
  end

  def changed?
    @data.reduce(false) { |memo, chap| memo ||= chap.changed? }
  end

  def load!(file : String = @file) : Void
    @data = Array(ChapItem).from_json(File.read(file))
    puts "- <chap_seed> [#{file.colorize(:cyan)}] loaded."
  end

  def save!(file : String = @file) : Void
    File.write(file, to_json)
    puts "- <chap_seed> [#{@file.colorize(:cyan)}] saved."
  end

  # class methods

  DIR = File.join("var", "appcv", "chap_seeds")
  FileUtils.mkdir_p(DIR)

  def self.glob_dir : Array(String)
    Dir.glob(File.join(DIR, "*.json"))
  end

  def self.load!(seed : String, sbid : String)
    new(seed, sbid, preload: true)
  end
end
