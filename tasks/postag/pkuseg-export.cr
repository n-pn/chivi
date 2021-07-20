require "./_postag"

class CV::Export
  DIR     = "_db/vpinit"
  INP_DIR = "#{DIR}/pkuseg"
  OUT_DIR = "#{DIR}/corpus/pkuseg"

  def merge!(redo = false)
    File.each_line("priv/zhseed.tsv") do |line|
      next if line.empty?
      sname, snvid, bhash, bslug = line.split('\t')

      inp_dir = "#{INP_DIR}/#{sname}/#{snvid}"
      next unless File.exists?(inp_dir)

      out_file = "#{OUT_DIR}/raw/#{bhash}.tsv"
      next unless redo || !File.exists?(out_file)

      merge_dir(inp_dir, out_file)
    end
  end

  def merge_dir(inp_dir : String, out_file : String, mode = 0)
    output = CV::Tagsum.new(out_file, mode: mode)

    Dir.glob("#{inp_dir}/*.dat").each do |file|
      output.load_postag!(file)
    end

    output.save!
  end

  getter should_skips : Set(String) do
    output = Set(String).new

    File.each_line("#{DIR}/corpus/pfrtag.top.tsv") do |line|
      frags = line.split('\t', 2)
      next if frags.size < 2
      output.add(frags.first)
    end

    puts "- should_skips: #{output.size} entries"
    output
  end

  alias Counter = Hash(String, Int32)

  getter words = Hash(String, Counter).new { |h, k| h[k] = Counter.new(0) }
  getter books = Hash(String, Int32).new(0)

  def export!
    files = Dir.glob("#{OUT_DIR}/raw/*.tsv")

    files.each do |inp_file|
      out_file = inp_file.sub("raw/", "")
      add_postag(inp_file, out_file)
    end

    save_books!
    save_words!
  end

  def add_postag(inp_file : String, out_file : String)
    out_io = File.open(out_file, "w")
    counts = 0

    File.each_line(inp_file) do |line|
      frags = line.split('\t')
      next if frags.size < 2
      counts += 1

      word = frags[0]
      @books[word] += 1

      next if should_skips.includes?(word)
      should_print = false

      frags[1..].each do |frag|
        tag, count = frag.split(':', 2)
        count = count.to_i
        next if count < 4

        should_print = true
        @words[word][tag] += count
      end

      out_io.puts(line) if should_print
    end

    out_io.close
    puts "- <pkuseg> file #{inp_file} loaded, entries: #{counts}!"
  end

  def save_books!(file = "#{DIR}/corpus/pkuseg-books.tsv")
    output = @books.to_a
    output.reject!(&.[1].< 8)
    output.sort_by!(&.[1].-)

    file_io = File.open(file, "w")

    output.each do |word, count|
      file_io << word << '\t' << count << '\n'
    end

    puts "- #{file} saved, entries: #{output.size}}"
    file_io.close
  end

  def save_words!(file = "#{DIR}/corpus/pkuseg-words.tsv")
    output = @words.to_a.compact_map do |word, counter|
      counter = counter.to_a.sort_by(&.[1].-)
      next if counter[0][1] < 20
      {word, counter}
    end

    output.reject! { |w, _| @books[w] < 8 }
    output.sort_by! { |_, c| -c[0][1] }

    file_io = File.open(file, "w")
    best_io = File.open("#{DIR}/corpus/pkuseg-bests.tsv", "w")

    output.each do |word, counter|
      emit(file_io, word, counter)
      emit(best_io, word, counter) if decent?(counter)
    end

    puts "- #{file} saved, entries: #{output.size}}"
    file_io.close
    best_io.close
  end

  def emit(io : IO, word, counter)
    io << word

    counter.each do |tag, count|
      io << '\t' << tag << ':' << count
    end

    io << '\n'
  end

  def decent?(counter)
    best = counter[0][1]
    return false unless best >= 50
    return true if counter.size == 1

    second_best = counter[1][1]
    return true if second_best < 10

    best - second_best >= 50
  end

  def self.run!(argv = ARGV)
    redo = argv.includes?("-r")
    task = new
    task.merge!(redo: redo)
    task.export!
  end
end

CV::Export.run!(ARGV)
