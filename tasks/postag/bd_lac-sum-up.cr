require "colorize"
require "file_utils"
require "../../"

INP = "_db/vpinit/bd_lac/raw"
OUT = "_db/vpinit/bd_lac/sum"

class Counter
  getter counter : PostagInit
  getter checked = Set(String).new

  def initialize(@bslug : String, @redo = false)
    @inp_dir = File.join(INP, @bslug)

    @log_file = File.join(OUT, @bslug + ".log")

    @counter = Counter.new(File.join(OUT, @bslug + ".tsv"), reset: @redo)
    @checked.concat(File.read_lines(@log_file)) unless @redo
  end

  def count! : Nil
    Dir.glob("#{@inp_dir}/*.tsv").each do |inp_file|
      fbase = File.basename(inp_file)
      next if @checked.includes?(fbase)

      @counter.load(inp_file)
      @checked << fbase
    end
  end

  def save!
    @counter.save!(sort: true)
    File.open(@log_file, "w", @checked.join('\n'))
  end
end

redo = ARGV.includes?("--redo")

Dir.children(INP).each do |bslug|
  puts bslug
  counter = Counter.new(bslug, redo: redo).tap(&.count!)
  counter.save!
end

# def add_to_total(channel : Channel(Folder), all_books : Counter, all_ptags : Counter)
#   folder = channel.receive

#   average = folder.checked.size // 2 &+ 1

#   folder.counter.data.each do |word, counts|
#     best_tag = counts.to_a.sort_by(&.[1].-)[0][0]

#     all_books.update_count(word, best_tag, 1)

#     counts.each do |tag, count|
#       count = (count - 1) // average &+ 1
#       all_ptags.update_count(word, tag, count)
#     end
#   end
# end

# dirs = Dir.children(DIR)

# all_books = Counter.new("_db/vpinit/lac-books.tsv")
# all_ptags = Counter.new("_db/vpinit/lac-ptags.tsv")

# workers = ENV["CRYSTAL_WORKERS"]?.try(&.to_i) || 6
# channel = Channel(Folder).new(workers)

# redo = ARGV.includes?("--redo")

# dirs.each_with_index(1) do |dir_name, idx|
#   spawn do
#     channel.send sum_up_dir(dir_name, redo: redo, lbl: "#{idx}/#{dirs.size}")
#   end

#   if idx > workers
#     add_to_total(channel, all_books, all_ptags)
#   end
# end

# workers.times { add_to_total(channel, all_books, all_ptags) }

# all_books.save_output(sort: true)
# all_ptags.save_output(sort: true)
