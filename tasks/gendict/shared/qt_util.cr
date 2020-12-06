require "colorize"
require "file_utils"

require "../../../src/engine/library"

class ValueSet
  getter file : String
  getter data = Set(String).new
  forward_missing_to @data

  def initialize(@file)
    load!(@file) if File.exists?(@file)
  end

  def load!(file : String = @file)
    File.each_line(file) do |line|
      key, val = line.split('\t')

      case val
      when "T" then @data.add(key)
      when "F" then @data.delete(key)
      end
    rescue err
      puts "[ERROR loading #{file}: #{err}, line: #{line}]".colorize.red
    end
  end

  def add(key : String)
    return unless @data.add(key)
    File.open(@file, "a") { |io| io.puts "#{key}\tT" }
  end

  def delete(key : String)
    return unless @data.delete(key)
    File.open(@file, "a") { |io| io.puts "#{key}\tF" }
  end
end

module QtUtil
  extend self

  INP_DIR = "_db/cvdict/_inits"
  OUT_DIR = "_db/cvdict/active"

  def inp_path(file : String)
    File.join(INP_DIR, file)
  end

  def out_path(file : String)
    File.join(OUT_DIR, file)
  end

  class_getter lexicon : ValueSet { ValueSet.new(inp_path(".result/lexicon.tsv")) }

  def has_hanzi?(input : String)
    input =~ /\p{Han}/
  end

  PINYINS = Hash(String, String).from_json {{ read_file("#{__DIR__}/binh_am.json") }}

  def fix_pinyin(input : String)
    input
      .downcase
      .gsub("u:", "ü")
      .split(/[\s\-]/x)
      .map { |x| PINYINS.fetch(x, x) }
      .join(" ")
  end

  def convert(dict : Chivi::VpDict, text : String, join = "")
    res = [] of String

    chars = text.chars
    from = 0

    while from < chars.size
      char = chars[from]
      keep = Chivi::VpTerm.new(char.to_s, [char.to_s])

      dict.scan(chars, from) do |term|
        keep = term unless term.vals.first.empty?
      end

      res << keep.vals.first
      from += keep.key.size
    end

    res.join(join)
  end
end
