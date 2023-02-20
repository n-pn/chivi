require "../../../_util/hash_util"
require "../../../_util/ram_cache"

require "compress/zip"

class CV::QtranData
  DIR = "tmp/qtrans"

  spawn do
    `find #{DIR} -type f -atime +1 -delete`
  end

  CACHE = RamCache(String, self).new(2048, 10.minutes)

  def self.load!(type : String, ukey : String, stale = Time.utc) : QtranData
    CACHE.get(type + "/" + ukey, stale) { reload!(type, ukey) }
  end

  def self.reload!(type : String, ukey : String)
    # puts "reload: #{type}/#{ukey}"

    case type
    when "posts" then load_file(File.join(DIR, ukey + ".txt"))
    when "crits" then load_crit(ukey)
    when "repls" then load_repl(ukey)
      # when "chaps" then load_chap(ukey)
    else raise "Unsupported type"
    end
  end

  def self.load_file(file : String) : QtranData
    lines = File.read_lines(file)
    dname, d_lbl, count, label = lines.shift.split('\t')
    new(lines, dname, d_lbl, count.to_i, label)
  end

  # def self.load_chap(name : String, mode : Int8 = 0, uname = "") : QtranData
  #   sname, s_bid, ch_no, cpart = name.split(":")

  #   unless chroot = Chroot.find({sname: sname, s_bid: s_bid.to_i})
  #     raise NotFound.new("Nguồn truyện không tồn tại")
  #   end

  #   unless chinfo = chroot.chinfo(ch_no.to_i)
  #     raise NotFound.new("Chương tiết không tồn tại")
  #   end

  #   load_chap(chroot, chinfo, cpart.to_i16, mode, uname)
  # end

  # def self.load_chap(chroot : Chroot, chinfo : Chinfo,
  #                    cpart = 0_i16, mode : Int8 = 0, uname = "")
  #   input = chinfo.text(cpart, mode: mode, uname: uname)
  #   chroot._repo.upsert(chinfo)
  #   lines = input.empty? ? [] of String : input.split('\n')

  #   p_len = chinfo.p_len
  #   label = p_len > 1 ? " [#{cpart &+ 1}/#{p_len}]" : ""

  #   nvinfo = chroot.nvinfo
  #   new(lines, nvinfo.dname, nvinfo.vname, label: label)
  # end

  CRIT_URL = "localhost:5400/_ys/crits"
  REPL_URL = "localhost:5400/_ys/repls"

  def self.load_crit(name : String) : QtranData
    self.load_text_from_url("#{CRIT_URL}/#{name}/ztext")
  end

  def self.load_repl(name : String) : QtranData
    self.load_text_from_url("#{REPL_URL}/#{name}/ztext")
  end

  def self.load_text_from_url(url : String)
    HTTP::Client.get(url) do |res|
      body = res.body_io.gets_to_end
      raise NotFound.new(body) unless res.status.success?

      dname = res.headers["X-DNAME"]
      bname = res.headers["X-BNAME"]

      new(parse_lines(body), dname, bname)
    end
  end

  def self.parse_lines(ztext : String) : Array(String)
    ztext = ztext.gsub("\t", "  ")
    TextUtil.split_text(ztext, spaces_as_newline: false)
  end

  def self.get_d_lbl(dname : String)
    return "Tổng hợp" unless dname[0]? == '-'
    return "Không rõ" unless nvinfo = Nvinfo.find({bhash: dname[1..]})
    nvinfo.vname
  end

  @@counter = 0

  def self.post_ukey : String
    @@counter &+= 1
    HashUtil.encode32(Time.local.to_unix_ms &+ @@counter)
  end

  ################

  SEP = "$\t$\t$"

  enum Format
    Text; Html; Node
  end

  getter input : Array(String)
  getter simps : Array(String) { input }

  getter dname : String
  getter d_lbl : String
  getter count : Int32

  def initialize(@input, @dname = "", @d_lbl = "",
                 @count = input.sum(&.size), @label = "")
  end

  def save!(ukey : String) : Nil
    file = File.join(DIR, ukey + ".txt")

    File.open(file, "w") do |io|
      {@dname, @d_lbl, @count, @label}.join(io, '\t')
      @input.each { |line| io << '\n' << line }
    end
  end

  getter simps : Array(String) do
    Process.run("/usr/bin/opencc", {"-c", "hk2s"}) do |proc|
      @input.each { |line| proc.input.puts(line) }
      proc.input.close
      proc.output.gets_to_end.lines
    rescue err
      Log.error(exception: err) { err.message }
      @input
    end
  end

  def make_engine(user : String = "", with_temp : Bool = false)
    wn_id = M1::DbDict.get_id(@dname)
    M1::MtCore.generic_mtl(wn_id, user, with_temp)
  end

  def print_mtl(engine, output : IO,
                format : Format = :node,
                title : Bool = true,
                trad : Bool = false)
    lines = trad ? self.simps : @input
    stime = Time.monotonic

    header = lines[0]

    begin
      mtdata = title ? engine.cv_title_full(header) : engine.cv_plain(header)
      format.text? ? mtdata.to_txt(output) : mtdata.to_mtl(output)
    rescue err
      Log.error(exception: err) { header }
      output << "[[Lỗi máy dịch, mời liên hệ ban quản trị!]]"
    end

    output << '\t' << @label unless @label.empty?

    lines[1..].each do |line|
      output << '\n'
      mtdata = engine.cv_plain(line)
      format.text? ? mtdata.to_txt(output) : mtdata.to_mtl(output)
    rescue err
      Log.error(exception: err) { line }
      output << "[[Lỗi máy dịch, mời liên hệ ban quản trị!]]"
    end

    output << '\n' << SEP << '\n'

    tspan = (Time.monotonic - stime).total_milliseconds.round.to_i
    {@dname, @d_lbl, @count, tspan, engine.dicts.last.size}.join(output, '\t')
  end

  def print_raw(output : IO)
    output << '\n' << SEP
    lines = @simps || @input
    lines.each { |line| output << '\n' << line }
  end
end
