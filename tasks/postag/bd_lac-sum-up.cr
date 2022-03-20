require "colorize"
require "file_utils"

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

  def load_parsed(file : String = @file)
    File.each_line(file) do |line|
      next if line.empty?
      input = line.split(SEP_1)

      term = input.first
      next if term.empty?

      input[1..].each do |counts|
        tag, count = counts.split(SEP_2, 2)
        @data[term][tag] &+= count.to_i
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

        @data[term][tag] &+= 1
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

class Folder
  def initialize(@dir : String)
    @sum_file = File.join(@dir, "_all.sum")
    @log_file = File.join(@dir, "_all.log")

    @counter = Counter.new(@sum_file)
    @checked = Set(String).new

    return unless File.exists?(@log_file)

    @counter.load_parsed
    @checked.concat(File.read_lines(@log_file))
  end

  def count_files(inps : Array(String)) : Nil
    inps.each do |inp_file|
      basename = File.basename(inp_file)
      next if @checked.includes?(basename)

      # txt_file = inp_file.sub(/.tsv$/, ".txt")
      # File.delete(txt_file) if File.exists?(txt_file)

      out_file = inp_file.sub(/.tsv$/, ".sum")
      counter = Counter.new(out_file)

      inp_time = File.info(inp_file).modification_time
      if counter.outdated?(inp_time)
        counter.parse_lac(inp_file)
        counter.save_output(out_file)
      else
        counter.load_parsed(out_file)
      end

      @checked << basename
      @counter.merge(counter)
    end
  end

  def save_counter
    @counter.save_output(sort: true)

    File.open(@log_file, "a") do |io|
      io.puts(@checked.join('\n'))
    end
  end
end

REDO = ARGV.includes?("--redo")

DIR = "_db/vpinit/bd_lac"

Dir.children(DIR).each do |dir_name|
  dir_path = File.join(DIR, dir_name)

  tsv_files = Dir.glob("#{dir_path}/*.tsv")
  puts "- #{dir_name} has #{tsv_files.size} files"

  if tsv_files.empty?
    FileUtils.rm_rf(dir_path)
    next
  end

  folder = Folder.new(dir_path)
  folder.count_files(tsv_files)
  folder.save_counter
end
