require "../_util/ukey_util"
require "../_util/ram_cache"

class CV::QtranData
  DIR = "tmp/qtrans"

  {"chaps", "posts", "crits", "repls", "lists", "descs"}.each do |type|
    Dir.mkdir_p("#{DIR}/#{type}")
  end

  spawn do
    `find #{DIR} -type f -atime +1 -delete`
  end

  def self.path(name : String, type : String = "chaps")
    "#{DIR}/#{type}/#{name}.txt"
  end

  def self.load(file : String) : QtranData | Nil
    return unless File.exists?(file)
    lines = File.read_lines(file)

    dname, d_lbl, count, label = lines.shift.split('\t')
    new(lines, dname, d_lbl, count.to_i, label)
  end

  alias Cache = RamCache(String, QtranData)

  CACHE = Hash(String, Cache).new { |h, k| h[k] = Cache.new(2048, 1.hours) }

  def self.load_cached(ukey : String, type = "chaps", disk = true) : QtranData
    CACHE[type].get(ukey) do
      file = path(ukey, type)
      load(file) || yield.tap { |x| x.save!(file) if disk }
    end
  end

  def self.clear_cache(type : String, disk = true)
    CACHE[type].clear
    `rm #{DIR}/#{type}/*.txt` if disk
  end

  def self.clear_cache(type : String, ukey : String, disk = true)
    CACHE[type].delete(ukey)
    return unless disk
    file = "#{DIR}/#{type}/#{ukey}.txt"
    File.delete(file) if File.exists?(file)
  end

  def self.clear_chaps_cache(seed_id : Int64, chidx : Int32, parts : Int32, disk = true)
    ukey = nvchap_ukey(seed_id, chidx)

    parts.times do |cpart|
      clear_cache("chaps", "#{ukey}-#{cpart}", disk: disk)
    end
  end

  @@counter = 0

  def self.qtpost_ukey : String
    @@counter &+= 1
    CV::UkeyUtil.encode32(Time.local.to_unix_ms &+ @@counter)
  end

  def self.nvchap_ukey(seed_id : Int64, chidx : Int32) : String
    number = chidx.to_i64.unsafe_shl(21) | seed_id
    CV::UkeyUtil.encode32(number)
  end

  def self.nvchap_ukey(seed_id : Int64, chidx : Int32, cpart : Int32) : String
    "#{nvchap_ukey(seed_id, chidx)}-#{cpart}"
  end

  def self.nvchap_ukey_decode(string : String)
    digest, cpart = string.split("-", 2)
    number = CV::UkeyUtil.decode32(digest)
    seed_id = number % 1.unsafe_shl(21)
    chidx = number.unsafe_shr(21)
    {seed_id, chidx.to_i, cpart.to_i}
  end

  ##############

  getter input : Array(String)
  getter simps : Array(String) { input }

  getter dname : String
  getter d_lbl : String
  getter count : Int32

  def initialize(@input, @dname = "", @d_lbl = "",
                 @count = input.sum(&.size), @label = "")
  end

  def save!(file : String) : Nil
    File.open(file, "w") do |io|
      {@dname, @d_lbl, @count, @label}.join(io, '\t')
      @input.each { |line| io << '\n' << line }
    end
  end

  SEP = "$\t$\t$"

  enum Format
    Text; Html; Node
  end

  def print_mtl(engine, output : IO,
                format : Format = :node,
                title : Bool = true,
                trad : Bool = false)
    lines = trad ? self.simps : @input
    stime = Time.monotonic

    tokens = title ? engine.cv_title_full(lines[0]) : engine.cv_plain(lines[0])
    format.text? ? tokens.to_s(output) : tokens.to_str(output)
    output << '\t' << @label unless @label.empty?

    1.upto(lines.size - 1) do |i|
      line = lines.unsafe_fetch(i)
      output << '\n'
      tokens = engine.cv_plain(line)
      format.text? ? tokens.to_s(output) : tokens.to_str(output)
    end

    output << '\n' << SEP << '\n'

    tspan = (Time.monotonic - stime).total_milliseconds.round.to_i
    {@dname, @d_lbl, @count, tspan}.join(output, '\t')
  end

  def print_raw(output : IO)
    output << '\n' << SEP
    lines = @simps || @input
    lines.each { |line| output << '\n' << line }
  end
end
