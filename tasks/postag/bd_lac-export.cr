require "colorize"
require "file_utils"

DIR = "_db/vpinit/bd_lac"

class Counter
  alias CountTag = Hash(String, Int32)
  alias CountStr = Hash(String, CountTag)

  SEP_1 = '\t'
  SEP_2 = '¦'

  getter data : CountStr

  def initialize(@file : String)
    @data = CountStr.new do |h, k|
      h[k] = CountTag.new { |h2, k2| h2[k2] = 0 }
    end
  end

  def outdated?(time : Time)
    return true unless info = File.info?(@file)
    info.modification_time < time
  end

  @[AlwaysInline]
  def update_count(term : String, tag : String, count = 1)
    @data[term][tag] &+= count
  end

  def load_parsed(file : String = @file)
    File.each_line(file) do |line|
      next if line.empty?
      input = line.split(SEP_1)

      term = input.first
      next if term.empty?

      input[1..].each do |counts|
        tag, count = counts.split(SEP_2, 2)
        update_count(term, tag, count.to_i)
      end
    end
  end

  def save_output(file : String = @file, sort = false)
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
        counts.each do |tag, count|
          io << SEP_1 << tag << SEP_2 << count
        end
        io << '\n'
      end
    end
  end

  def parse_lac(file : String)
    File.each_line(file) do |line|
      line.split(SEP_1) do |word|
        list = word.split(' ')

        next unless tag = list.pop?
        term = list.size == 1 ? list.first : list.join(' ')

        update_count(term, tag, 1)
      end
    end
  end

  def merge(other : self)
    other.data.each do |term, counts|
      counts.each do |tag, count|
        @data[term][tag] &+= count
      end
    end
  end
end

all_books = Counter.new("_db/vpinit/lac-books.tsv").tap(&.load_parsed)
# all_ptags = Counter.new("_db/vpinit/lac-ptags.tsv").tap(&.load_parsed)
