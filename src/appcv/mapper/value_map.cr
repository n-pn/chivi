require "../../../src/utils/time_util"

class Appcv::ValueMap
  class Node
    getter key : String
    getter val : String
    getter alt : String

    getter mtime : Int32
    getter extra : String

    def initialize(@key, @val, @alt = "", @mtime = TimeUtil.mtime, @extra = "")
    end

    def self.from(line : String, trunc = false)
      cls = line.split('\t', 5)

      key = cls[0]
      val = cls[1]? || ""
      alt = cls[2]? || ""

      if trunc || !(mtime = cls[3]?.try(&.to_i?))
        return new(key, val, alt, mtime: 0)
      end

      extra = cls[4]? || ""
      new(key, val, alt, mtime: mtime, extra: extra)
    end
  end

  class_property cwd = File.join("var", "appcv")
  class_property tab = "appcv"

  def self.load(map : String, tab = @@tap, cwd = @cwd, renew = false)
    tsv_file = File.join(cwd, "#{map}.tsv")
    tab_file = File.join(cwd, "#{map}.#{tab}.tab")

    this = new(tsv_file, tab_file)
    renew ? this : this.load(tsv_file).load(tab_file)
  end

  getter tsv_file : String
  getter tab_file : String

  getter hash = {} of String => String
  delegate size, to: @hash
  delegate each, to: @hash
  delegate has_key?, to: @hash

  def initialize(@tsv_file, @tab_file)
  end

  def load(file : String) : self
    load(file) do |line|
      cls = line.split('\t')
      key = cls[0]

      if val = cls[1]?
        upsert(key, val)
      else
        delete(key)
      end
    rescue err
      puts "- <#{value_map}> error parsing `#{line}` : #{err}".colorize.red
    end

    self
  end

  def load(file : String) : Nil
    return unless File.exists?(file)
    count = 0

    time = Time.measure do
      File.each_line(file) do |line|
        line = line.strip
        next if line.blank?

        yield line
        count += 1
      end
    end

    time = time.total_milliseconds.round.to_i
    puts "- <#{value_map}> [#{file}] loaded (lines: #{count}, time: #{time}ms)".colorize.blue
  end

  def upsert(key : String, val : String)
  end
end
