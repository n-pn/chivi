require "colorize"
require "./chap_item"

class ChapList
  DIR = File.join("var", "appcv", "chap_lists")

  def self.files : Array(String)
    Dir.glob(File.join(DIR, "*.json"))
  end

  def self.load!(seed : String, sbid : String)
    new(seed, sbid, preload: true)
  end

  getter seed : String
  getter sbid : String

  getter file : String
  getter data = [] of ChapItem

  def initialize(@seed : String, @sbid : String, preload : Bool = false)
    @file = File.join(DIR, "#{@seed}.#{@sbid}.json")

    load!(@file) if preload
  end

  include Enumerable(ChapItem)
  delegate each, to: @data

  def load! : ChapList
    if File.exists?(@file)
      @data = Array(ChapItem).from_json(File.read(@file))
      puts "- <chap_list> [#{@file.colorize(:cyan)}] loaded."
    else
      puts "- <chap_list> [#{@file.colorize(:cyan)}] not found!"
    end

    self
  end

  def exists?
    File.exists?(@file)
  end

  def save! : ChapList
    File.write(@file, @data.to_json)
    puts "- <chap_list> [#{@file.colorize(:cyan)}] saved."

    self
  end
end
