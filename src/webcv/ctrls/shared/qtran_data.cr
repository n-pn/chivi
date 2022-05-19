class CV::QtranData
  enum Mode
    Text; Html; Node
  end

  getter input : Array(String)
  getter dname : String
  getter d_lbl : String
  getter chars : Int32

  def initialize(@input, @dname = "combine", @d_lbl = "",
                 @chars = input.sum(&.size), @title = false, @label = "")
  end

  getter simps : Array(String) do
    @input.map { |x| MtCore.trad_to_simp(x) }
  end

  SEP = "$\t$\t$"

  def print_mtl(output : IO, uname : String = "",
                mode : Mode = :node, trad : Bool = false)
    return if input.empty?
    cvmtl = MtCore.generic_mtl(@dname, uname)
    lines = trad ? self.simps : @input

    stime = Time.monotonic

    result = @title ? cvmtl.cv_title_full(lines[0]) : cvmtl.cv_plain(lines[0])
    mode.text? ? result.to_s(output) : result.to_str(output)
    output << '\t' << @label unless @label.empty?

    1.upto(lines.size - 1) do |i|
      line = lines.unsafe_fetch(i)
      result = cvmtl.cv_plain(line, cap_first: true)

      output << '\n'
      mode.text? ? result.to_s(output) : result.to_str(output)
    end

    output << "\n#{SEP}\n"

    tspan = (Time.monotonic - stime).total_milliseconds.round.to_i
    {@dname, @d_lbl, @chars, tspan}.join(output, '\t')
  end

  def print_raw(output : IO)
    output << "\n#{SEP}"

    lines = @simps || @input
    lines.each { |line| output << '\n' << line }
  end

  def save!(file_name : String, uname : String) : Nil
    file_path = File.join(@@curr_dir, file_name)
    File.open(file_path, "w") do |io|
      {@dname, @d_lbl, @chars, uname}.join(io, '\t')
      @input.each { |line| io << '\n' << line }
    end
  end

  #####

  DIR = "var/qttexts"

  @@curr_dir = File.join(DIR, TimeUtil.get_date(Time.local))
  @@prev_dir = File.join(DIR, TimeUtil.get_date(Time.local - 1.day))

  Dir.mkdir_p(@@curr_dir)

  spawn do
    loop do
      sleep 24.hours
      @@curr_dir = Path[DIR, TimeUtil.get_date(Time.local)]
      Dir.mkdir_p(@@curr_dir)
      @@prev_dir = Path[DIR, TimeUtil.get_date(Time.local - 1.day)]
    end
  end

  CACHE = RamCache(String, self).new(2048, 6.hours)

  def self.load!(ukey : String)
    CACHE.get(ukey) { yield }
  end

  def self.from_file(ukey : String)
    file_name = "#{ukey}.txt"
    read_file(File.join(@@curr_dir, file_name)) || read_file(File.join(@@prev_dir, file_name))
  end

  def self.read_file(file_path : String) : self | Nil
    return unless File.exists?(file_path)
    lines = File.read_lines(file_path)

    dname, d_lbl, chars = lines.shift.split('\t')
    new(lines, dname, d_lbl, chars.to_i)
  end

  def self.get_d_lbl(dname : String)
    return "Tổng hợp" unless dname[0]? == '-'
    return "Không rõ" unless nvinfo = Nvinfo.find({bhash: dname[1..]})
    nvinfo.vname
  end

  @@counter = 0

  def self.post_ukey : String
    @@counter &+= 1
    UkeyUtil.encode32(Time.local.to_unix_ms &+ @@counter)
  end

  def self.text_ukey(seed_id : Int64, chidx : Int32, cpart : Int32) : String
    number = chidx.unsafe_shl(20) | seed_id
    "#{UkeyUtil.encode32(number)}-#{cpart}"
  end

  def self.text_ukey_parse(string : String)
    digest, cpart = string.split("-", 2)
    number = UkeyUtil.decode32(digest)
    seed_id = number % 1.unsafe_shl(20)
    chidx = number.unsafe_shr(20)
    {seed_id, chidx.to_i, cpart.to_i}
  end

  def self.zhtext(nvinfo : Nvinfo, lines : Array(String), parts : Int32, cpart : Int32)
    dname = nvinfo.dname
    d_lbl = nvinfo.vname

    label = parts > 1 ? " [#{cpart + 1}/#{parts}]" : ""
    new(lines, dname, d_lbl, title: true, label: label)
  end
end
