require "colorize"
require "file_utils"
require "../../src/_init/postag_init"

RAW = "_db/vpinit/bd_lac/raw"
TMP = "_db/vpinit/bd_lac/tmp"
SUM = "_db/vpinit/bd_lac/sum"

class CV::CountDir
  getter batch : PostagInit
  getter check = Set(String).new

  @has_error = false

  def initialize(@bslug : String, @redo = false, @purge = false)
    @raw_dir = File.join(RAW, @bslug)
    @tmp_dir = File.join(TMP, @bslug)
    Dir.mkdir_p(@tmp_dir)

    @sum_file = File.join(SUM, @bslug + ".tsv")
    @log_file = File.join(SUM, @bslug + ".log")

    @batch = PostagInit.new(@sum_file, reset: @redo)

    if !@redo && File.exists?(@log_file)
      @check.concat(File.read_lines(@log_file))
    end
  end

  def count! : Nil
    Dir.glob("#{@raw_dir}/*.tsv").each do |raw_file|
      fbase = File.basename(raw_file)
      next if @check.includes?(fbase)

      tmp_file = File.join(@tmp_dir, fbase)
      next unless single = load_chap(raw_file, tmp_file)

      single.data.each do |term, counts|
        counts.each { |tag, count| @batch.update_count(term, tag, count) }
      end

      @check.add(fbase)
    rescue err
      Log.error { err }
    end
  end

  def load_chap(raw_file : String, tmp_file : String) : PostagInit?
    counter = CV::PostagInit.new(tmp_file, reset: true)

    if File.exists?(tmp_file)
      counter.load!(tmp_file)
    else
      counter.load_raw!(raw_file)
      counter.save!
    end

    counter
  rescue err
    Log.error { [raw_file, tmp_file, err].colorize.red }

    if @purge
      @has_error = true
      File.delete(raw_file)
      File.delete(tmp_file) if File.exists?(tmp_file)
    end
  end

  def save!
    @batch.save!(sort: true)
    File.write(@log_file, @check.to_a.join("\n"))
    File.open("_db/vpinit/bd_lac/error.log", "a", &.puts(@bslug)) if @has_error
  end

  ##########

  REDO  = ARGV.includes?("--redo")
  PURGE = ARGV.includes?("--purge")

  def self.sum_up!
    workers = ENV["CRYSTAL_WORKERS"]?.try(&.to_i) || 6
    channel = Channel(Nil).new(workers)

    dirs = ARGV.reject(&.starts_with?("-"))
    dirs = Dir.children(RAW) if dirs.empty?
    workers = dirs.size if workers > dirs.size

    dirs.each_with_index(1) do |bslug, idx|
      channel.receive if idx > workers

      spawn do
        Log.info { "<#{idx}/#{bslug}>".colorize.yellow }
        counter = new(bslug, REDO, PURGE)
        counter.count!
        counter.save!
      rescue err
        puts err
      ensure
        channel.send(nil)
      end
    end

    workers.times { channel.receive }
  end

  sum_up!
end
