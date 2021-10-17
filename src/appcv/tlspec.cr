require "../cutil/ukey_util"

class CV::Tlspec
  DIR = "db/tlspecs"

  CACHE = {} of String => self

  def self.load!(ukey : String, mode = 1) : self
    CACHE[ukey] ||= new(ukey, mode: mode)
  end

  def self.init! : self
    ukey = UkeyUtil.gen_ukey
    items.unshift(ukey)
    load!(ukey, mode: 0)
  end

  class_getter items : Array(String) do
    Dir.glob("#{DIR}/*.tsv")
      .sort_by { |x| File.info(x).modification_time.to_unix.- }
      .map { |x| File.basename(x, ".tsv") }
  end

  getter file : String
  getter ukey : String

  property ztext : String = ""

  property unote : String = ""   # expected result/translation note
  property uname : String? = nil # original poster uname

  property dname : String = "combine" # unique dict used
  property slink : String = "."       # source link

  property ctime : Int64 = 0_i64
  property utime : Int64? = nil

  property status : Int32 = 0 # 0: pending, 1: checking, 2: resolved, 3: duplicate, 4: wontfix
  property labels : Array(String) = [] of String

  getter _logs = [] of Array(String)

  def initialize(@ukey : String, mode : Int32 = 1)
    @file = "#{DIR}/#{@ukey}.tsv"
    return unless mode > 0 && File.exists?(@file)
    File.read_lines(@file).each { |line| push(line.split('\t')) }
  end

  # format: [mtime uname field value...]
  def push(rows : Array(String)) : Bool
    @_logs << rows

    case rows[0]?
    when "ztext", "zhtxt"
      @ztext = rows[1]? || "???"
    when "_orig"
      @ctime = @utime = parse_time(rows[2]?)
      @dname = rows[1]? || "combine"
      @slink = rows[2]? || "."
    when "_note"
      @uname = rows[1]? || "_"
      @unote = rows[2]? || ""
    else
      @utime = parse_time(rows[0]?)
      # uname = rows[2]? || "_"

      case rows[1]?
      when "unote"
        @unote = rows[3]? || ""
      when "state"
        @status = rows[3]?.try(&.to_i?) || 0
      when "label"
        @labels = rows[3..]
      end
    end

    true
  end

  def parse_time(input : String?)
    input.try(&.to_i64?) || 0_i64
  end

  def push!(rows : Array(String))
    return unless push(rows)
    File.open(@file, "a") { |io| io.puts(rows.join('\t')) }
  end

  def push!(type : String, *value : String)
    push!([Time.utc.to_unix.to_s, type].concat(value))
  end

  def save!
    File.open(@file, "w") do |io|
      @_logs.each { |rows| io.puts rows.join('\t') }
    end
  end
end
