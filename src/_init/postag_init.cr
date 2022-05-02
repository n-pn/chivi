require "tabkv"
require "../cvmtl/vp_dict"

class CV::PostagInit
  alias CountTag = Hash(String, Int32)
  alias CountStr = Hash(String, CountTag)

  SEP_1 = '\t'
  SEP_2 = '¦'

  getter data : CountStr

  def initialize(@file : String, reset = false)
    @data = CountStr.new do |h, k|
      h[k] = CountTag.new { |h2, k2| h2[k2] = 0 }
    end

    load!(@file) if !reset && File.exists?(@file)
  end

  def load!(file : String = @file)
    lines = File.read_lines(file)

    lines.each do |line|
      next if line.empty?

      rows = line.split(SEP_1)
      term = rows.shift

      rows.each do |entry|
        tag, count = entry.split(SEP_2, 2)
        update_count(term, tag, count.to_i)
      end
    end

    Log.info { "[postag] #{file} loaded, entries: #{lines.size} " }
  end

  def load_raw!(file : String)
    File.each_line(file) do |line|
      line.split(SEP_1) do |frag|
        term, tag = frag.split(SEP_2, 2)
        update_count(term, tag.in?("nt", "ns") ? "nn" : tag, 1)
      end
    end
  end

  @[AlwaysInline]
  def update_count(term : String, tag : String, count = 1)
    @data[term][tag] &+= count
  end

  def save!(file : String = @file, sort = false)
    File.open(file, "w") do |io|
      if sort
        output = @data.to_a
        output.sort_by! do |term, counts|
          {-counts.values.sum, -term.size}
        end
      else
        output = @data
      end

      output.each do |term, counts|
        io << term

        counts.to_a.sort_by(&.[1].-).each do |tag, count|
          io << SEP_1 << tag << SEP_2 << count
        end

        io << '\n'
      end
    end
  end
end
