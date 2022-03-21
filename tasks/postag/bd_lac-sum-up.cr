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

class Folder
  getter counter : Counter
  getter checked = Set(String).new

  def initialize(@dir : String, @redo = false)
    @sum_file = File.join(@dir, "_all.sum")
    @log_file = File.join(@dir, "_all.log")

    @counter = Counter.new(@sum_file)

    return if @redo || !File.exists?(@log_file)

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
      if @redo || counter.outdated?(inp_time)
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

def sum_up_dir(dir_name : String, redo = false, lbl = "1/1")
  dir_path = File.join(DIR, dir_name)

  tsv_files = Dir.glob("#{dir_path}/*.tsv")
  puts "- <#{lbl}> #{dir_name} has #{tsv_files.size} files"

  folder = Folder.new(dir_path, redo: redo)

  folder.count_files(tsv_files)
  folder.save_counter

  folder
end

def add_to_total(channel : Channel(Folder), all_books : Counter, all_ptags : Counter)
  folder = channel.receive

  average = folder.checked.size // 2 &+ 1

  folder.counter.data.each do |word, counts|
    best_tag = counts.to_a.sort_by(&.[1].-)[0][0]

    all_books.update_count(word, best_tag, 1)

    counts.each do |tag, count|
      count = (count - 1) // average &+ 1
      all_ptags.update_count(word, tag, count)
    end
  end
end

dirs = Dir.children(DIR)

all_books = Counter.new("_db/vpinit/lac-books.tsv")
all_ptags = Counter.new("_db/vpinit/lac-ptags.tsv")

workers = ENV["CRYSTAL_WORKERS"]?.try(&.to_i) || 6
channel = Channel(Folder).new(workers)

redo = ARGV.includes?("--redo")

dirs.each_with_index(1) do |dir_name, idx|
  spawn do
    channel.send sum_up_dir(dir_name, redo: redo, lbl: "#{idx}/#{dirs.size}")
  end

  if idx > workers
    add_to_total(channel, all_books, all_ptags)
  end
end

workers.times { add_to_total(channel, all_books, all_ptags) }

all_books.save_output(sort: true)
all_ptags.save_output(sort: true)
